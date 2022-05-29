'''
Module for getting user password type from the Accounts service
'''

'''
 Copyright (C) 2022  Maciej Sopylo

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 waydroidhelper is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import dbus
from enum import Enum


class PasswordMode(Enum):
    """
    Password mode
    """
    REGULAR = 0
    """
    Password is set
    """
    SET_AT_LOGIN = 1
    """
    Password will be set at login
    """
    NONE = 2
    """
    No password
    """


class PasswordDisplayHint(Enum):
    """
    Which display hint to use for a prompt
    """
    KEYBOARD = 0
    """
    Full keyboard
    """
    NUMERIC = 1
    """
    Just numbers
    """


class PasswordType(Enum):
    """
    Password type
    """
    KEYBOARD = 0
    """
    Any text
    """
    NUMERIC = 1
    """
    Numbers only
    """
    NONE = 99
    """
    No password
    """
    UNKNOWN = 100
    """
    Unknown
    """


def get_password_type():
    """
    Get a password type from the Accounts service

    Returns
    -------
    PasswordType
        password type depending on user's settings
    """
    bus = dbus.SystemBus()

    try:
        accounts = bus.get_object(
            'org.freedesktop.Accounts', '/org/freedesktop/Accounts')
        path = accounts.FindUserByName(
            'phablet', dbus_interface='org.freedesktop.Accounts')

        user = bus.get_object('org.freedesktop.Accounts', path)
        password_mode = PasswordMode(
            user.Get(
                'org.freedesktop.Accounts.User',
                'PasswordMode',
                dbus_interface='org.freedesktop.DBus.Properties'
            )
        )

        if password_mode == PasswordMode.NONE:
            return PasswordType.NONE
        elif password_mode == PasswordMode.SET_AT_LOGIN:
            return PasswordType.UNKNOWN

        password_hint = PasswordDisplayHint(
            user.Get(
                'com.ubuntu.AccountsService.SecurityPrivacy',
                'PasswordDisplayHint',
                dbus_interface='org.freedesktop.DBus.Properties'
            )
        )

        if password_hint == PasswordDisplayHint.KEYBOARD:
            return PasswordType.KEYBOARD
        elif password_hint == PasswordDisplayHint.NUMERIC:
            return PasswordType.NUMERIC
    finally:
        bus.close()

    return PasswordType.UNKNOWN
