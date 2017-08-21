
typedef enum {
   Ev_dud = 0,
   Ev_friend_request = 1,
   Ev_friend_message = 2,
} EvTp;

// Catchall object.
typedef struct Tox_CB_Event {
   EvTp tp;
   uint32_t friend_number;
   TOX_MESSAGE_TYPE type;
   uint8_t *message; size_t length;
//   char* 
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
void ToxEvents_iterate(ToxEvents* s);
