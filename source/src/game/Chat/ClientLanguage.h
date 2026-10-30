#pragma once

// ComfyCraft: the language id that a packet sends to the client. With
// AllowTwoSide.Interaction.Chat on, Common and Orcish go out as Universal, so
// both factions read them. The racial languages are not changed. The client
// garbles text in a language that its player does not know.
//
// Used by ChatHandler::BuildChatPacket (SMSG_MESSAGECHAT) and by the two
// SMSG_NPC_TEXT_UPDATE builders (PlayerMenu::SendTalking and
// WorldSession::HandleNpcTextQueryOpcode). Defined in Chat.cpp.

#include "Common.h"

uint32 LanguageForClient(uint32 language);
