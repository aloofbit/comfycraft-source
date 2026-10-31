#pragma once

// Login letters: a letter that is on goes by mail to each character when it
// logs in, once (sql/custom/225_login_letters.sql). Defined in
// CharacterHandler.cpp, beside the login.
//
// The website's Login letters page (/admin/loginletters) writes the letters in
// tw_char; they are read at each login. The sender is "ComfyCraft Staff"
// (creature 100041) on the staff letter paper. Bots and companions get none.

#include "Common.h"

class Player;

namespace LoginLetter
{
    // At start-up: probe the two tables. Without them nothing is read or
    // written, since a missing table is ASSERT(false) in HandleMySQLError.
    void Load();
    bool TablesPresent();

    // The character logged in. Asks for its letters without waiting; they are
    // sent on the world thread when the answer comes.
    void OnLogin(Player* player);
}
