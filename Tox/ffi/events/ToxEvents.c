#include<stdlib.h>  // For malloc, realloc.
#include <tox/tox.h>

#include "ToxEvents.h"

ToxEvents* ToxEvents_init(ToxEvents* s, Tox* tox) {
   s->tox = tox;
   s->use_cnt = 0; s->space_cnt = 16;  // TODO increase initial count.
   // Make space.
   s->events = (Tox_CB_Event*)malloc(sizeof(Tox_CB_Event)*s->space_cnt);
   s->events[0].tp = Ev_dud;  // End marker.
   return s;
}

ToxEvents* new_ToxEvents(Tox* tox) {
   return ToxEvents_init((ToxEvents*)malloc(sizeof(ToxEvents)), tox);
}

void ToxEvents_ensure_space(ToxEvents* s) {
   if( s->use_cnt >= s->space_cnt ) {  // Ran out of space, double.
      s->space_cnt *= 2;
      s->events = (Tox_CB_Event*)realloc((void*)s->events,  s->space_cnt);
      s->events[s->use_cnt].tp = Ev_dud;  // Ensure end marker.
   }
}
/*
void tox_callback_friend_read_receipt(Tox *tox, tox_friend_read_receipt_cb *callback);
void tox_callback_file_recv_control(Tox *tox, tox_file_recv_control_cb *callback);
void tox_callback_file_chunk_request(Tox *tox, tox_file_chunk_request_cb *callback);
void tox_callback_file_recv(Tox *tox, tox_file_recv_cb *callback);
void tox_callback_file_recv_chunk(Tox *tox, tox_file_recv_chunk_cb *callback);
void tox_callback_conference_invite(Tox *tox, tox_conference_invite_cb *callback);
void tox_callback_conference_message(Tox *tox, tox_conference_message_cb *callback);
void tox_callback_conference_title(Tox *tox, tox_conference_title_cb *callback);
void tox_callback_conference_namelist_change(Tox *tox, tox_conference_namelist_change_cb *callback);
void tox_callback_friend_lossy_packet(Tox *tox, tox_friend_lossy_packet_cb *callback);
void tox_callback_friend_lossless_packet(Tox *tox, tox_friend_lossless_packet_cb *callback);
*/

// Registers callbacks needed to get data needed for the events.

void tox_ev_friend_request_cb(Tox *tox, const uint8_t *public_key,
                              const uint8_t *message, size_t length,
                              void *user_data) {
   ToxEvents* s = (ToxEvents*)user_data;
   ToxEvents_ensure_space(s);
   Tox_CB_Event* event = s->events + s->use_cnt;  // Set it.
   event->tp = Ev_friend_request;
   event->friend_number = 0; //(dont care)
   event->type = 0; //(dont care)
   event->message = message;
   event->length = length;
   s->use_cnt ++;  // Indicate that one is used.
}

void tox_ev_friend_message_cb(Tox *tox,
                              uint32_t friend_number, TOX_MESSAGE_TYPE type, const uint8_t *message,
                              size_t length, void *user_data) {
   ToxEvents* s = (ToxEvents*)user_data;
   ToxEvents_ensure_space(s);
   Tox_CB_Event* event = s->events + s->use_cnt;  // Set it.
   event->tp = Ev_friend_message;
   event->friend_number = friend_number;
   event->type = type;
   event->message = message;
   event->length = length;
   s->use_cnt ++;  // Indicate that one is used.
}

void ToxEvents_register_callbacks(ToxEvents* s) {
   tox_callback_friend_request(s->tox, tox_ev_friend_request_cb);
   tox_callback_friend_message(s->tox, tox_ev_friend_message_cb);
   // TODO more of them.
}

// Not returning pointers, because `realloc` may invalidate them.

// NOTE: dont care about the pointers afterwards.
// * Think lua will free the pointers when no longer references as far as it is concerned.
// * It shouldn't contain any pointers from the earlier value, those wiped as callbacks add
//     events.
Tox_CB_Event ToxEvents_poll(ToxEvents* s) {
   if( s->use_cnt > 0 ) {
      s->use_cnt--;
      return s->events[s->use_cnt];
   } else {
      s->events[0].tp = Ev_dud;
      return s->events[0];
   }
}
// Does the iteration thing.
// NOTE: Do the rest directly with s->tox; this just this way because need userdata.
void ToxEvents_iterate(ToxEvents* s) {
   tox_iterate(s->tox, (void*)s);
}
