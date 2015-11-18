/*
 *  UserLogConfig.h
 *  Utils
 *
 *  Created by Boris Godin on 8/25/10.
 *  Copyright 2014 NGT International B.V. All rights reserved.
 *
 */
#ifndef _USER_LOG_H_
#define _USER_LOG_H_

//--------------------------------------------------------
// Note that git will ignore changes made in this file.
// This file will ONLY be included in DEBUG mode.
//--------------------------------------------------------

// Nothing of log.
//#define NO_LOG

// Log to console.
#define LOG_TO_CONSOLE

// Log only stanzas (note that warnings and errors are logged always).
// #define LOG_ONLY_STANZAS

#ifdef LOG_ONLY_STANZAS
#	define MIN_TYPE_FOR_LOG         INFO
#	define ENABLED_LOG_COMPONENTS   NET, JINGLE
#else
	// Will only log for your type or greater. Types are DBG, INFO, WARNING, ERROR, FATAL.
#	define MIN_TYPE_FOR_LOG         DBG

	// Components that are enabled when application starts. Must be comma separated. 
	// 0 disable all, -1 enable all components. Check out LogComponent type. 
	// Example: #define ENABLED_LOG_COMPONENTS NET, JINGLE, P2P
#	define ENABLED_LOG_COMPONENTS   NET, JINGLE, P2P, VIDEO, DEFAULT, XMPP, LOGIN, SESSION, BACKGROUNDMODE, INAPPPURCHASE
#endif

#endif // _USER_LOG_H_

