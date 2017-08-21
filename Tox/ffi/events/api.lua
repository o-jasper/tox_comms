return [[ 
typedef enum {
   Ev_dud = 0,
//   Ev_connection_status = 10,
   Ev_friend_message = 90,
   Ev_friend_request = 100,
   Ev_friend_connection_status = 101,
   Ev_friend_status = 102,
   Ev_friend_status_message = 103,
   Ev_friend_name = 104,
} EvTp;

// Catchall object.
typedef struct Tox_CB_Event {
   EvTp tp;
   uint32_t friend_number;
   union {  // NOTE: can certainly imagine subtle bugs, so do away with union if needed.
      TOX_MESSAGE_TYPE type;
      TOX_USER_STATUS status;
      TOX_CONNECTION connection_status;
   };
   union{ uint8_t *message; uint8_t *name; };
   size_t length;
} Tox_CB_Event;

typedef struct ToxEvents {
   Tox* tox;
   int use_cnt, space_cnt;
   Tox_CB_Event* events;
} ToxEvents;

ToxEvents* new_ToxEvents(Tox* tox);

void ToxEvents_register_callbacks(ToxEvents* s);

Tox_CB_Event ToxEvents_poll(ToxEvents* s);

// Must use this one, otherwise wrong userdata=>segfault.
void ToxEvents_iterate(ToxEvents* s); ]]
