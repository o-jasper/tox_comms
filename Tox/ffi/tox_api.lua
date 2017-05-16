return [[ 
typedef long int ptrdiff_t;
typedef long unsigned int size_t;
typedef int wchar_t;
typedef struct {
  long long __max_align_ll __attribute__((__aligned__(__alignof__(long long))));
  long double __max_align_ld __attribute__((__aligned__(__alignof__(long double))));
} max_align_t;


typedef unsigned char __u_char;
typedef unsigned short int __u_short;
typedef unsigned int __u_int;
typedef unsigned long int __u_long;


typedef signed char __int8_t;
typedef unsigned char __uint8_t;
typedef signed short int __int16_t;
typedef unsigned short int __uint16_t;
typedef signed int __int32_t;
typedef unsigned int __uint32_t;

typedef signed long int __int64_t;
typedef unsigned long int __uint64_t;







typedef long int __quad_t;
typedef unsigned long int __u_quad_t;







typedef long int __intmax_t;
typedef unsigned long int __uintmax_t;


typedef unsigned long int __dev_t;
typedef unsigned int __uid_t;
typedef unsigned int __gid_t;
typedef unsigned long int __ino_t;
typedef unsigned long int __ino64_t;
typedef unsigned int __mode_t;
typedef unsigned long int __nlink_t;
typedef long int __off_t;
typedef long int __off64_t;
typedef int __pid_t;
typedef struct { int __val[2]; } __fsid_t;
typedef long int __clock_t;
typedef unsigned long int __rlim_t;
typedef unsigned long int __rlim64_t;
typedef unsigned int __id_t;
typedef long int __time_t;
typedef unsigned int __useconds_t;
typedef long int __suseconds_t;

typedef int __daddr_t;
typedef int __key_t;


typedef int __clockid_t;


typedef void * __timer_t;


typedef long int __blksize_t;




typedef long int __blkcnt_t;
typedef long int __blkcnt64_t;


typedef unsigned long int __fsblkcnt_t;
typedef unsigned long int __fsblkcnt64_t;


typedef unsigned long int __fsfilcnt_t;
typedef unsigned long int __fsfilcnt64_t;


typedef long int __fsword_t;

typedef long int __ssize_t;


typedef long int __syscall_slong_t;

typedef unsigned long int __syscall_ulong_t;



typedef __off64_t __loff_t;
typedef __quad_t *__qaddr_t;
typedef char *__caddr_t;


typedef long int __intptr_t;


typedef unsigned int __socklen_t;
typedef signed char int8_t;
typedef short int int16_t;
typedef int int32_t;

typedef long int int64_t;







typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;

typedef unsigned int uint32_t;



typedef unsigned long int uint64_t;
typedef signed char int_least8_t;
typedef short int int_least16_t;
typedef int int_least32_t;

typedef long int int_least64_t;






typedef unsigned char uint_least8_t;
typedef unsigned short int uint_least16_t;
typedef unsigned int uint_least32_t;

typedef unsigned long int uint_least64_t;
typedef signed char int_fast8_t;

typedef long int int_fast16_t;
typedef long int int_fast32_t;
typedef long int int_fast64_t;
typedef unsigned char uint_fast8_t;

typedef unsigned long int uint_fast16_t;
typedef unsigned long int uint_fast32_t;
typedef unsigned long int uint_fast64_t;
typedef long int intptr_t;


typedef unsigned long int uintptr_t;
typedef __intmax_t intmax_t;
typedef __uintmax_t uintmax_t;

typedef struct Tox Tox;
uint32_t tox_version_major(void);
uint32_t tox_version_minor(void);







uint32_t tox_version_patch(void);

_Bool 
    tox_version_is_compatible(uint32_t major, uint32_t minor, uint32_t patch);
uint32_t tox_public_key_size(void);






uint32_t tox_secret_key_size(void);






uint32_t tox_nospam_size(void);
uint32_t tox_address_size(void);






uint32_t tox_max_name_length(void);






uint32_t tox_max_status_message_length(void);






uint32_t tox_max_friend_request_length(void);






uint32_t tox_max_message_length(void);






uint32_t tox_max_custom_packet_size(void);






uint32_t tox_hash_length(void);






uint32_t tox_file_id_length(void);






uint32_t tox_max_filename_length(void);
typedef enum TOX_USER_STATUS {




    TOX_USER_STATUS_NONE,





    TOX_USER_STATUS_AWAY,





    TOX_USER_STATUS_BUSY,

} TOX_USER_STATUS;






typedef enum TOX_MESSAGE_TYPE {




    TOX_MESSAGE_TYPE_NORMAL,





    TOX_MESSAGE_TYPE_ACTION,

} TOX_MESSAGE_TYPE;
typedef enum TOX_PROXY_TYPE {




    TOX_PROXY_TYPE_NONE,




    TOX_PROXY_TYPE_HTTP,




    TOX_PROXY_TYPE_SOCKS5,

} TOX_PROXY_TYPE;





typedef enum TOX_SAVEDATA_TYPE {




    TOX_SAVEDATA_TYPE_NONE,




    TOX_SAVEDATA_TYPE_TOX_SAVE,




    TOX_SAVEDATA_TYPE_SECRET_KEY,

} TOX_SAVEDATA_TYPE;





typedef enum TOX_LOG_LEVEL {




    TOX_LOG_LEVEL_TRACE,




    TOX_LOG_LEVEL_DEBUG,




    TOX_LOG_LEVEL_INFO,




    TOX_LOG_LEVEL_WARNING,




    TOX_LOG_LEVEL_ERROR,

} TOX_LOG_LEVEL;
typedef void tox_log_cb(Tox *tox, TOX_LOG_LEVEL level, const char *file, uint32_t line, const char *func,
                        const char *message, void *user_data);
struct Tox_Options {
    
   _Bool 
        ipv6_enabled;
    
   _Bool 
        udp_enabled;







    
   _Bool 
        local_discovery_enabled;





    TOX_PROXY_TYPE proxy_type;
    const char *proxy_host;
    uint16_t proxy_port;
    uint16_t start_port;





    uint16_t end_port;
    uint16_t tcp_port;





    
   _Bool 
        hole_punching_enabled;





    TOX_SAVEDATA_TYPE savedata_type;
    const uint8_t *savedata_data;





    size_t savedata_length;





    tox_log_cb *log_callback;





    void *log_user_data;

};



_Bool 
    tox_options_get_ipv6_enabled(const struct Tox_Options *options);

void tox_options_set_ipv6_enabled(struct Tox_Options *options, 
                                                              _Bool 
                                                                   ipv6_enabled);


_Bool 
    tox_options_get_udp_enabled(const struct Tox_Options *options);

void tox_options_set_udp_enabled(struct Tox_Options *options, 
                                                             _Bool 
                                                                  udp_enabled);


_Bool 
    tox_options_get_local_discovery_enabled(const struct Tox_Options *options);

void tox_options_set_local_discovery_enabled(struct Tox_Options *options, 
                                                                         _Bool 
                                                                              local_discovery_enabled);

TOX_PROXY_TYPE tox_options_get_proxy_type(const struct Tox_Options *options);

void tox_options_set_proxy_type(struct Tox_Options *options, TOX_PROXY_TYPE type);

const char *tox_options_get_proxy_host(const struct Tox_Options *options);

void tox_options_set_proxy_host(struct Tox_Options *options, const char *host);

uint16_t tox_options_get_proxy_port(const struct Tox_Options *options);

void tox_options_set_proxy_port(struct Tox_Options *options, uint16_t port);

uint16_t tox_options_get_start_port(const struct Tox_Options *options);

void tox_options_set_start_port(struct Tox_Options *options, uint16_t start_port);

uint16_t tox_options_get_end_port(const struct Tox_Options *options);

void tox_options_set_end_port(struct Tox_Options *options, uint16_t end_port);

uint16_t tox_options_get_tcp_port(const struct Tox_Options *options);

void tox_options_set_tcp_port(struct Tox_Options *options, uint16_t tcp_port);


_Bool 
    tox_options_get_hole_punching_enabled(const struct Tox_Options *options);

void tox_options_set_hole_punching_enabled(struct Tox_Options *options, 
                                                                       _Bool 
                                                                            hole_punching_enabled);

TOX_SAVEDATA_TYPE tox_options_get_savedata_type(const struct Tox_Options *options);

void tox_options_set_savedata_type(struct Tox_Options *options, TOX_SAVEDATA_TYPE type);

const uint8_t *tox_options_get_savedata_data(const struct Tox_Options *options);

void tox_options_set_savedata_data(struct Tox_Options *options, const uint8_t *data, size_t length);

size_t tox_options_get_savedata_length(const struct Tox_Options *options);

void tox_options_set_savedata_length(struct Tox_Options *options, size_t length);

tox_log_cb *tox_options_get_log_callback(const struct Tox_Options *options);

void tox_options_set_log_callback(struct Tox_Options *options, tox_log_cb *callback);

void *tox_options_get_log_user_data(const struct Tox_Options *options);

void tox_options_set_log_user_data(struct Tox_Options *options, void *user_data);
void tox_options_default(struct Tox_Options *options);

typedef enum TOX_ERR_OPTIONS_NEW {




    TOX_ERR_OPTIONS_NEW_OK,




    TOX_ERR_OPTIONS_NEW_MALLOC,

} TOX_ERR_OPTIONS_NEW;
struct Tox_Options *tox_options_new(TOX_ERR_OPTIONS_NEW *error);







void tox_options_free(struct Tox_Options *options);
typedef enum TOX_ERR_NEW {




    TOX_ERR_NEW_OK,




    TOX_ERR_NEW_NULL,





    TOX_ERR_NEW_MALLOC,






    TOX_ERR_NEW_PORT_ALLOC,




    TOX_ERR_NEW_PROXY_BAD_TYPE,





    TOX_ERR_NEW_PROXY_BAD_HOST,




    TOX_ERR_NEW_PROXY_BAD_PORT,




    TOX_ERR_NEW_PROXY_NOT_FOUND,




    TOX_ERR_NEW_LOAD_ENCRYPTED,
    TOX_ERR_NEW_LOAD_BAD_FORMAT,

} TOX_ERR_NEW;
Tox *tox_new(const struct Tox_Options *options, TOX_ERR_NEW *error);
void tox_kill(Tox *tox);







size_t tox_get_savedata_size(const Tox *tox);
void tox_get_savedata(const Tox *tox, uint8_t *savedata);
typedef enum TOX_ERR_BOOTSTRAP {




    TOX_ERR_BOOTSTRAP_OK,




    TOX_ERR_BOOTSTRAP_NULL,





    TOX_ERR_BOOTSTRAP_BAD_HOST,




    TOX_ERR_BOOTSTRAP_BAD_PORT,

} TOX_ERR_BOOTSTRAP;

_Bool 
    tox_bootstrap(Tox *tox, const char *address, uint16_t port, const uint8_t *public_key, TOX_ERR_BOOTSTRAP *error);

_Bool 
    tox_add_tcp_relay(Tox *tox, const char *address, uint16_t port, const uint8_t *public_key,
                       TOX_ERR_BOOTSTRAP *error);




typedef enum TOX_CONNECTION {





    TOX_CONNECTION_NONE,






    TOX_CONNECTION_TCP,







    TOX_CONNECTION_UDP,

} TOX_CONNECTION;






TOX_CONNECTION tox_self_get_connection_status(const Tox *tox);




typedef void tox_self_connection_status_cb(Tox *tox, TOX_CONNECTION connection_status, void *user_data);
void tox_callback_self_connection_status(Tox *tox, tox_self_connection_status_cb *callback);





uint32_t tox_iteration_interval(const Tox *tox);





void tox_iterate(Tox *tox, void *user_data);
void tox_self_get_address(const Tox *tox, uint8_t *address);
void tox_self_set_nospam(Tox *tox, uint32_t nospam);





uint32_t tox_self_get_nospam(const Tox *tox);







void tox_self_get_public_key(const Tox *tox, uint8_t *public_key);







void tox_self_get_secret_key(const Tox *tox, uint8_t *secret_key);
typedef enum TOX_ERR_SET_INFO {




    TOX_ERR_SET_INFO_OK,




    TOX_ERR_SET_INFO_NULL,




    TOX_ERR_SET_INFO_TOO_LONG,

} TOX_ERR_SET_INFO;

_Bool 
    tox_self_set_name(Tox *tox, const uint8_t *name, size_t length, TOX_ERR_SET_INFO *error);
size_t tox_self_get_name_size(const Tox *tox);
void tox_self_get_name(const Tox *tox, uint8_t *name);

_Bool 
    tox_self_set_status_message(Tox *tox, const uint8_t *status_message, size_t length, TOX_ERR_SET_INFO *error);
size_t tox_self_get_status_message_size(const Tox *tox);
void tox_self_get_status_message(const Tox *tox, uint8_t *status_message);






void tox_self_set_status(Tox *tox, TOX_USER_STATUS status);




TOX_USER_STATUS tox_self_get_status(const Tox *tox);
typedef enum TOX_ERR_FRIEND_ADD {




    TOX_ERR_FRIEND_ADD_OK,




    TOX_ERR_FRIEND_ADD_NULL,





    TOX_ERR_FRIEND_ADD_TOO_LONG,





    TOX_ERR_FRIEND_ADD_NO_MESSAGE,




    TOX_ERR_FRIEND_ADD_OWN_KEY,





    TOX_ERR_FRIEND_ADD_ALREADY_SENT,




    TOX_ERR_FRIEND_ADD_BAD_CHECKSUM,




    TOX_ERR_FRIEND_ADD_SET_NEW_NOSPAM,




    TOX_ERR_FRIEND_ADD_MALLOC,

} TOX_ERR_FRIEND_ADD;
uint32_t tox_friend_add(Tox *tox, const uint8_t *address, const uint8_t *message, size_t length,
                        TOX_ERR_FRIEND_ADD *error);
uint32_t tox_friend_add_norequest(Tox *tox, const uint8_t *public_key, TOX_ERR_FRIEND_ADD *error);

typedef enum TOX_ERR_FRIEND_DELETE {




    TOX_ERR_FRIEND_DELETE_OK,




    TOX_ERR_FRIEND_DELETE_FRIEND_NOT_FOUND,

} TOX_ERR_FRIEND_DELETE;

_Bool 
    tox_friend_delete(Tox *tox, uint32_t friend_number, TOX_ERR_FRIEND_DELETE *error);
typedef enum TOX_ERR_FRIEND_BY_PUBLIC_KEY {




    TOX_ERR_FRIEND_BY_PUBLIC_KEY_OK,




    TOX_ERR_FRIEND_BY_PUBLIC_KEY_NULL,




    TOX_ERR_FRIEND_BY_PUBLIC_KEY_NOT_FOUND,

} TOX_ERR_FRIEND_BY_PUBLIC_KEY;
uint32_t tox_friend_by_public_key(const Tox *tox, const uint8_t *public_key, TOX_ERR_FRIEND_BY_PUBLIC_KEY *error);






_Bool 
    tox_friend_exists(const Tox *tox, uint32_t friend_number);







size_t tox_self_get_friend_list_size(const Tox *tox);
void tox_self_get_friend_list(const Tox *tox, uint32_t *friend_list);

typedef enum TOX_ERR_FRIEND_GET_PUBLIC_KEY {




    TOX_ERR_FRIEND_GET_PUBLIC_KEY_OK,




    TOX_ERR_FRIEND_GET_PUBLIC_KEY_FRIEND_NOT_FOUND,

} TOX_ERR_FRIEND_GET_PUBLIC_KEY;

_Bool 
    tox_friend_get_public_key(const Tox *tox, uint32_t friend_number, uint8_t *public_key,
                               TOX_ERR_FRIEND_GET_PUBLIC_KEY *error);

typedef enum TOX_ERR_FRIEND_GET_LAST_ONLINE {




    TOX_ERR_FRIEND_GET_LAST_ONLINE_OK,




    TOX_ERR_FRIEND_GET_LAST_ONLINE_FRIEND_NOT_FOUND,

} TOX_ERR_FRIEND_GET_LAST_ONLINE;
uint64_t tox_friend_get_last_online(const Tox *tox, uint32_t friend_number, TOX_ERR_FRIEND_GET_LAST_ONLINE *error);
typedef enum TOX_ERR_FRIEND_QUERY {




    TOX_ERR_FRIEND_QUERY_OK,






    TOX_ERR_FRIEND_QUERY_NULL,




    TOX_ERR_FRIEND_QUERY_FRIEND_NOT_FOUND,

} TOX_ERR_FRIEND_QUERY;
size_t tox_friend_get_name_size(const Tox *tox, uint32_t friend_number, TOX_ERR_FRIEND_QUERY *error);

_Bool 
    tox_friend_get_name(const Tox *tox, uint32_t friend_number, uint8_t *name, TOX_ERR_FRIEND_QUERY *error);
typedef void tox_friend_name_cb(Tox *tox, uint32_t friend_number, const uint8_t *name, size_t length, void *user_data);







void tox_callback_friend_name(Tox *tox, tox_friend_name_cb *callback);





size_t tox_friend_get_status_message_size(const Tox *tox, uint32_t friend_number, TOX_ERR_FRIEND_QUERY *error);

_Bool 
    tox_friend_get_status_message(const Tox *tox, uint32_t friend_number, uint8_t *status_message,
                                   TOX_ERR_FRIEND_QUERY *error);
typedef void tox_friend_status_message_cb(Tox *tox, uint32_t friend_number, const uint8_t *message, size_t length,
        void *user_data);







void tox_callback_friend_status_message(Tox *tox, tox_friend_status_message_cb *callback);
TOX_USER_STATUS tox_friend_get_status(const Tox *tox, uint32_t friend_number, TOX_ERR_FRIEND_QUERY *error);






typedef void tox_friend_status_cb(Tox *tox, uint32_t friend_number, TOX_USER_STATUS status, void *user_data);







void tox_callback_friend_status(Tox *tox, tox_friend_status_cb *callback);
TOX_CONNECTION tox_friend_get_connection_status(const Tox *tox, uint32_t friend_number, TOX_ERR_FRIEND_QUERY *error);







typedef void tox_friend_connection_status_cb(Tox *tox, uint32_t friend_number, TOX_CONNECTION connection_status,
        void *user_data);
void tox_callback_friend_connection_status(Tox *tox, tox_friend_connection_status_cb *callback);

_Bool 
    tox_friend_get_typing(const Tox *tox, uint32_t friend_number, TOX_ERR_FRIEND_QUERY *error);







typedef void tox_friend_typing_cb(Tox *tox, uint32_t friend_number, 
                                                                   _Bool 
                                                                        is_typing, void *user_data);







void tox_callback_friend_typing(Tox *tox, tox_friend_typing_cb *callback);
typedef enum TOX_ERR_SET_TYPING {




    TOX_ERR_SET_TYPING_OK,




    TOX_ERR_SET_TYPING_FRIEND_NOT_FOUND,

} TOX_ERR_SET_TYPING;

_Bool 
    tox_self_set_typing(Tox *tox, uint32_t friend_number, 
                                                          _Bool 
                                                               typing, TOX_ERR_SET_TYPING *error);

typedef enum TOX_ERR_FRIEND_SEND_MESSAGE {




    TOX_ERR_FRIEND_SEND_MESSAGE_OK,




    TOX_ERR_FRIEND_SEND_MESSAGE_NULL,




    TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_FOUND,




    TOX_ERR_FRIEND_SEND_MESSAGE_FRIEND_NOT_CONNECTED,




    TOX_ERR_FRIEND_SEND_MESSAGE_SENDQ,




    TOX_ERR_FRIEND_SEND_MESSAGE_TOO_LONG,




    TOX_ERR_FRIEND_SEND_MESSAGE_EMPTY,

} TOX_ERR_FRIEND_SEND_MESSAGE;
uint32_t tox_friend_send_message(Tox *tox, uint32_t friend_number, TOX_MESSAGE_TYPE type, const uint8_t *message,
                                 size_t length, TOX_ERR_FRIEND_SEND_MESSAGE *error);






typedef void tox_friend_read_receipt_cb(Tox *tox, uint32_t friend_number, uint32_t message_id, void *user_data);
void tox_callback_friend_read_receipt(Tox *tox, tox_friend_read_receipt_cb *callback);
typedef void tox_friend_request_cb(Tox *tox, const uint8_t *public_key, const uint8_t *message, size_t length,
                                   void *user_data);







void tox_callback_friend_request(Tox *tox, tox_friend_request_cb *callback);






typedef void tox_friend_message_cb(Tox *tox, uint32_t friend_number, TOX_MESSAGE_TYPE type, const uint8_t *message,
                                   size_t length, void *user_data);







void tox_callback_friend_message(Tox *tox, tox_friend_message_cb *callback);

_Bool 
    tox_hash(uint8_t *hash, const uint8_t *data, size_t length);

enum TOX_FILE_KIND {





    TOX_FILE_KIND_DATA,
    TOX_FILE_KIND_AVATAR,

};


typedef enum TOX_FILE_CONTROL {





    TOX_FILE_CONTROL_RESUME,







    TOX_FILE_CONTROL_PAUSE,





    TOX_FILE_CONTROL_CANCEL,

} TOX_FILE_CONTROL;


typedef enum TOX_ERR_FILE_CONTROL {




    TOX_ERR_FILE_CONTROL_OK,




    TOX_ERR_FILE_CONTROL_FRIEND_NOT_FOUND,




    TOX_ERR_FILE_CONTROL_FRIEND_NOT_CONNECTED,




    TOX_ERR_FILE_CONTROL_NOT_FOUND,




    TOX_ERR_FILE_CONTROL_NOT_PAUSED,





    TOX_ERR_FILE_CONTROL_DENIED,




    TOX_ERR_FILE_CONTROL_ALREADY_PAUSED,




    TOX_ERR_FILE_CONTROL_SENDQ,

} TOX_ERR_FILE_CONTROL;

_Bool 
    tox_file_control(Tox *tox, uint32_t friend_number, uint32_t file_number, TOX_FILE_CONTROL control,
                      TOX_ERR_FILE_CONTROL *error);
typedef void tox_file_recv_control_cb(Tox *tox, uint32_t friend_number, uint32_t file_number, TOX_FILE_CONTROL control,
                                      void *user_data);
void tox_callback_file_recv_control(Tox *tox, tox_file_recv_control_cb *callback);

typedef enum TOX_ERR_FILE_SEEK {




    TOX_ERR_FILE_SEEK_OK,




    TOX_ERR_FILE_SEEK_FRIEND_NOT_FOUND,




    TOX_ERR_FILE_SEEK_FRIEND_NOT_CONNECTED,




    TOX_ERR_FILE_SEEK_NOT_FOUND,




    TOX_ERR_FILE_SEEK_DENIED,




    TOX_ERR_FILE_SEEK_INVALID_POSITION,




    TOX_ERR_FILE_SEEK_SENDQ,

} TOX_ERR_FILE_SEEK;

_Bool 
    tox_file_seek(Tox *tox, uint32_t friend_number, uint32_t file_number, uint64_t position, TOX_ERR_FILE_SEEK *error);

typedef enum TOX_ERR_FILE_GET {




    TOX_ERR_FILE_GET_OK,




    TOX_ERR_FILE_GET_NULL,




    TOX_ERR_FILE_GET_FRIEND_NOT_FOUND,




    TOX_ERR_FILE_GET_NOT_FOUND,

} TOX_ERR_FILE_GET;

_Bool 
    tox_file_get_file_id(const Tox *tox, uint32_t friend_number, uint32_t file_number, uint8_t *file_id,
                          TOX_ERR_FILE_GET *error);
typedef enum TOX_ERR_FILE_SEND {




    TOX_ERR_FILE_SEND_OK,




    TOX_ERR_FILE_SEND_NULL,




    TOX_ERR_FILE_SEND_FRIEND_NOT_FOUND,




    TOX_ERR_FILE_SEND_FRIEND_NOT_CONNECTED,




    TOX_ERR_FILE_SEND_NAME_TOO_LONG,





    TOX_ERR_FILE_SEND_TOO_MANY,

} TOX_ERR_FILE_SEND;
uint32_t tox_file_send(Tox *tox, uint32_t friend_number, uint32_t kind, uint64_t file_size, const uint8_t *file_id,
                       const uint8_t *filename, size_t filename_length, TOX_ERR_FILE_SEND *error);

typedef enum TOX_ERR_FILE_SEND_CHUNK {




    TOX_ERR_FILE_SEND_CHUNK_OK,




    TOX_ERR_FILE_SEND_CHUNK_NULL,




    TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_FOUND,




    TOX_ERR_FILE_SEND_CHUNK_FRIEND_NOT_CONNECTED,




    TOX_ERR_FILE_SEND_CHUNK_NOT_FOUND,





    TOX_ERR_FILE_SEND_CHUNK_NOT_TRANSFERRING,






    TOX_ERR_FILE_SEND_CHUNK_INVALID_LENGTH,




    TOX_ERR_FILE_SEND_CHUNK_SENDQ,




    TOX_ERR_FILE_SEND_CHUNK_WRONG_POSITION,

} TOX_ERR_FILE_SEND_CHUNK;

_Bool 
    tox_file_send_chunk(Tox *tox, uint32_t friend_number, uint32_t file_number, uint64_t position, const uint8_t *data,
                         size_t length, TOX_ERR_FILE_SEND_CHUNK *error);
typedef void tox_file_chunk_request_cb(Tox *tox, uint32_t friend_number, uint32_t file_number, uint64_t position,
                                       size_t length, void *user_data);







void tox_callback_file_chunk_request(Tox *tox, tox_file_chunk_request_cb *callback);
typedef void tox_file_recv_cb(Tox *tox, uint32_t friend_number, uint32_t file_number, uint32_t kind, uint64_t file_size,
                              const uint8_t *filename, size_t filename_length, void *user_data);







void tox_callback_file_recv(Tox *tox, tox_file_recv_cb *callback);
typedef void tox_file_recv_chunk_cb(Tox *tox, uint32_t friend_number, uint32_t file_number, uint64_t position,
                                    const uint8_t *data, size_t length, void *user_data);
void tox_callback_file_recv_chunk(Tox *tox, tox_file_recv_chunk_cb *callback);
typedef enum TOX_CONFERENCE_TYPE {




    TOX_CONFERENCE_TYPE_TEXT,




    TOX_CONFERENCE_TYPE_AV,

} TOX_CONFERENCE_TYPE;
typedef void tox_conference_invite_cb(Tox *tox, uint32_t friend_number, TOX_CONFERENCE_TYPE type, const uint8_t *cookie,
                                      size_t length, void *user_data);







void tox_callback_conference_invite(Tox *tox, tox_conference_invite_cb *callback);
typedef void tox_conference_message_cb(Tox *tox, uint32_t conference_number, uint32_t peer_number,
                                       TOX_MESSAGE_TYPE type, const uint8_t *message, size_t length, void *user_data);







void tox_callback_conference_message(Tox *tox, tox_conference_message_cb *callback);







typedef void tox_conference_title_cb(Tox *tox, uint32_t conference_number, uint32_t peer_number, const uint8_t *title,
                                     size_t length, void *user_data);
void tox_callback_conference_title(Tox *tox, tox_conference_title_cb *callback);




typedef enum TOX_CONFERENCE_STATE_CHANGE {




    TOX_CONFERENCE_STATE_CHANGE_PEER_JOIN,




    TOX_CONFERENCE_STATE_CHANGE_PEER_EXIT,




    TOX_CONFERENCE_STATE_CHANGE_PEER_NAME_CHANGE,

} TOX_CONFERENCE_STATE_CHANGE;







typedef void tox_conference_namelist_change_cb(Tox *tox, uint32_t conference_number, uint32_t peer_number,
        TOX_CONFERENCE_STATE_CHANGE change, void *user_data);







void tox_callback_conference_namelist_change(Tox *tox, tox_conference_namelist_change_cb *callback);

typedef enum TOX_ERR_CONFERENCE_NEW {




    TOX_ERR_CONFERENCE_NEW_OK,




    TOX_ERR_CONFERENCE_NEW_INIT,

} TOX_ERR_CONFERENCE_NEW;
uint32_t tox_conference_new(Tox *tox, TOX_ERR_CONFERENCE_NEW *error);

typedef enum TOX_ERR_CONFERENCE_DELETE {




    TOX_ERR_CONFERENCE_DELETE_OK,




    TOX_ERR_CONFERENCE_DELETE_CONFERENCE_NOT_FOUND,

} TOX_ERR_CONFERENCE_DELETE;

_Bool 
    tox_conference_delete(Tox *tox, uint32_t conference_number, TOX_ERR_CONFERENCE_DELETE *error);




typedef enum TOX_ERR_CONFERENCE_PEER_QUERY {




    TOX_ERR_CONFERENCE_PEER_QUERY_OK,




    TOX_ERR_CONFERENCE_PEER_QUERY_CONFERENCE_NOT_FOUND,




    TOX_ERR_CONFERENCE_PEER_QUERY_PEER_NOT_FOUND,




    TOX_ERR_CONFERENCE_PEER_QUERY_NO_CONNECTION,

} TOX_ERR_CONFERENCE_PEER_QUERY;





uint32_t tox_conference_peer_count(const Tox *tox, uint32_t conference_number, TOX_ERR_CONFERENCE_PEER_QUERY *error);




size_t tox_conference_peer_get_name_size(const Tox *tox, uint32_t conference_number, uint32_t peer_number,
        TOX_ERR_CONFERENCE_PEER_QUERY *error);








_Bool 
    tox_conference_peer_get_name(const Tox *tox, uint32_t conference_number, uint32_t peer_number, uint8_t *name,
                                  TOX_ERR_CONFERENCE_PEER_QUERY *error);








_Bool 
    tox_conference_peer_get_public_key(const Tox *tox, uint32_t conference_number, uint32_t peer_number,
                                        uint8_t *public_key, TOX_ERR_CONFERENCE_PEER_QUERY *error);





_Bool 
    tox_conference_peer_number_is_ours(const Tox *tox, uint32_t conference_number, uint32_t peer_number,
                                        TOX_ERR_CONFERENCE_PEER_QUERY *error);

typedef enum TOX_ERR_CONFERENCE_INVITE {




    TOX_ERR_CONFERENCE_INVITE_OK,




    TOX_ERR_CONFERENCE_INVITE_CONFERENCE_NOT_FOUND,




    TOX_ERR_CONFERENCE_INVITE_FAIL_SEND,

} TOX_ERR_CONFERENCE_INVITE;

_Bool 
    tox_conference_invite(Tox *tox, uint32_t friend_number, uint32_t conference_number,
                           TOX_ERR_CONFERENCE_INVITE *error);

typedef enum TOX_ERR_CONFERENCE_JOIN {




    TOX_ERR_CONFERENCE_JOIN_OK,




    TOX_ERR_CONFERENCE_JOIN_INVALID_LENGTH,




    TOX_ERR_CONFERENCE_JOIN_WRONG_TYPE,




    TOX_ERR_CONFERENCE_JOIN_FRIEND_NOT_FOUND,




    TOX_ERR_CONFERENCE_JOIN_DUPLICATE,




    TOX_ERR_CONFERENCE_JOIN_INIT_FAIL,




    TOX_ERR_CONFERENCE_JOIN_FAIL_SEND,

} TOX_ERR_CONFERENCE_JOIN;
uint32_t tox_conference_join(Tox *tox, uint32_t friend_number, const uint8_t *cookie, size_t length,
                             TOX_ERR_CONFERENCE_JOIN *error);

typedef enum TOX_ERR_CONFERENCE_SEND_MESSAGE {




    TOX_ERR_CONFERENCE_SEND_MESSAGE_OK,




    TOX_ERR_CONFERENCE_SEND_MESSAGE_CONFERENCE_NOT_FOUND,




    TOX_ERR_CONFERENCE_SEND_MESSAGE_TOO_LONG,




    TOX_ERR_CONFERENCE_SEND_MESSAGE_NO_CONNECTION,




    TOX_ERR_CONFERENCE_SEND_MESSAGE_FAIL_SEND,

} TOX_ERR_CONFERENCE_SEND_MESSAGE;

_Bool 
    tox_conference_send_message(Tox *tox, uint32_t conference_number, TOX_MESSAGE_TYPE type, const uint8_t *message,
                                 size_t length, TOX_ERR_CONFERENCE_SEND_MESSAGE *error);

typedef enum TOX_ERR_CONFERENCE_TITLE {




    TOX_ERR_CONFERENCE_TITLE_OK,




    TOX_ERR_CONFERENCE_TITLE_CONFERENCE_NOT_FOUND,




    TOX_ERR_CONFERENCE_TITLE_INVALID_LENGTH,




    TOX_ERR_CONFERENCE_TITLE_FAIL_SEND,

} TOX_ERR_CONFERENCE_TITLE;
size_t tox_conference_get_title_size(const Tox *tox, uint32_t conference_number, TOX_ERR_CONFERENCE_TITLE *error);

_Bool 
    tox_conference_get_title(const Tox *tox, uint32_t conference_number, uint8_t *title,
                              TOX_ERR_CONFERENCE_TITLE *error);

_Bool 
    tox_conference_set_title(Tox *tox, uint32_t conference_number, const uint8_t *title, size_t length,
                              TOX_ERR_CONFERENCE_TITLE *error);





size_t tox_conference_get_chatlist_size(const Tox *tox);





void tox_conference_get_chatlist(const Tox *tox, uint32_t *chatlist);





typedef enum TOX_ERR_CONFERENCE_GET_TYPE {




    TOX_ERR_CONFERENCE_GET_TYPE_OK,




    TOX_ERR_CONFERENCE_GET_TYPE_CONFERENCE_NOT_FOUND,

} TOX_ERR_CONFERENCE_GET_TYPE;


TOX_CONFERENCE_TYPE tox_conference_get_type(const Tox *tox, uint32_t conference_number,
        TOX_ERR_CONFERENCE_GET_TYPE *error);
typedef enum TOX_ERR_FRIEND_CUSTOM_PACKET {




    TOX_ERR_FRIEND_CUSTOM_PACKET_OK,




    TOX_ERR_FRIEND_CUSTOM_PACKET_NULL,




    TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_FOUND,




    TOX_ERR_FRIEND_CUSTOM_PACKET_FRIEND_NOT_CONNECTED,





    TOX_ERR_FRIEND_CUSTOM_PACKET_INVALID,




    TOX_ERR_FRIEND_CUSTOM_PACKET_EMPTY,




    TOX_ERR_FRIEND_CUSTOM_PACKET_TOO_LONG,




    TOX_ERR_FRIEND_CUSTOM_PACKET_SENDQ,

} TOX_ERR_FRIEND_CUSTOM_PACKET;

_Bool 
    tox_friend_send_lossy_packet(Tox *tox, uint32_t friend_number, const uint8_t *data, size_t length,
                                  TOX_ERR_FRIEND_CUSTOM_PACKET *error);

_Bool 
    tox_friend_send_lossless_packet(Tox *tox, uint32_t friend_number, const uint8_t *data, size_t length,
                                     TOX_ERR_FRIEND_CUSTOM_PACKET *error);






typedef void tox_friend_lossy_packet_cb(Tox *tox, uint32_t friend_number, const uint8_t *data, size_t length,
                                        void *user_data);






void tox_callback_friend_lossy_packet(Tox *tox, tox_friend_lossy_packet_cb *callback);






typedef void tox_friend_lossless_packet_cb(Tox *tox, uint32_t friend_number, const uint8_t *data, size_t length,
        void *user_data);






void tox_callback_friend_lossless_packet(Tox *tox, tox_friend_lossless_packet_cb *callback);
void tox_self_get_dht_id(const Tox *tox, uint8_t *dht_id);

typedef enum TOX_ERR_GET_PORT {




    TOX_ERR_GET_PORT_OK,




    TOX_ERR_GET_PORT_NOT_BOUND,

} TOX_ERR_GET_PORT;





uint16_t tox_self_get_udp_port(const Tox *tox, TOX_ERR_GET_PORT *error);





uint16_t tox_self_get_tcp_port(const Tox *tox, TOX_ERR_GET_PORT *error); ]]
