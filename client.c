#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>
#include <stdbool.h>
#include <string.h>

int main (int argc, const char * argv[]) {
	
	if (argc == 3) {
		char *end;
		uint16_t port = strtol(argv[2], &end, 0);
		
		printf("Attempting to connect to %s over port %i\n",argv[1],port);
		struct sockaddr_in primary, data;
		
		int32_t connection = socket(AF_INET, SOCK_STREAM, 0);
		memset(&primary, 0, sizeof(primary));
		primary.sin_family = AF_INET;
		primary.sin_port = htons(port);
		inet_aton(argv[1], &primary.sin_addr);
		
		uint16_t new_port, code;
		size_t received_bytes, sent_bytes;
		bool connection_status = (connect(connection, (struct sockaddr*)&primary, sizeof(primary)) != -1 ? true : false);
		if (connection_status) {
			printf("Connection Acquired\n");
			received_bytes = recv(connection, &new_port, sizeof(uint16_t), 0);
			new_port = ntohs(new_port);
			if (received_bytes > 0) {
				code = ((new_port < 49152) ? htons(500) : htons(1000));
				sent_bytes = send(connection, &code, sizeof(code), 0);
				received_bytes = recv(connection, &code, sizeof(uint16_t), 0);
				code = ntohs(code);
			}
		}
		printf("Response Code: %i -- %s\n",code, ((code == 1000) ? "Success" : ((code == 500) ? "Failure" : "Unknown Response")));
		close(connection);
		if (code == 1000) {
			int32_t data_connection = socket(AF_INET, SOCK_STREAM, 0);
			memset(&data, 0, sizeof(data));
			data.sin_family = AF_INET;
			data.sin_port = htons(new_port);
			inet_aton(argv[1], &data.sin_addr);
			bool data_connection_status = (connect(data_connection, (struct sockaddr*)&data, sizeof(data)) != -1 ? true : false);
			int64_t transmit_data;
			while (data_connection_status) {
				received_bytes = recv(data_connection, &transmit_data, sizeof(int64_t), 0);
				sent_bytes = send(data_connection, &transmit_data, sizeof(transmit_data), 0);
				data_connection_status = ((received_bytes > 0 && sent_bytes > 0) ? true : false);
			}
			close(data_connection);
		}

	}
	
    return 0;
}
