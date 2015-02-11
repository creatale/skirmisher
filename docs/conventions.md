# Event naming

Events are named thusly:
(where SYSTEM is the emitting system)

'SYSTEM:verb[-object]'
(when the system actively did something)

or (in rare cases)

'SYSTEM:subject-verb'
(when the system relays external events)

Event verbs be in the past tense.

for example an event emitted by TaleSystem:

'tale:generated-character'
'tale:device-crashed'

## Commands

Commands are special events, which enable one system to tell another that something should be done.
Use commands to separate concerns.

Commands are named thusly:
(where SYSTEM is the receiving system)

'SYSTEM:verb[-object]'

Command verbs are imperative.

For example:

'!tale:kill-character'

# Documentation

Each system has a comment header defining the following properties:

- name
- emitting events
- receiving events

for example:

DoorComponent = require '../components/door'

# TaleSystem
#	
#	[short description]
# 
# emits:
# 	- 'tale:generated-character', name
#	- 'tale:magic-happened', {complex, object} : explaining unintuitive magic effects
# 
# receives:
#	- 'mouse:click'
#	- 'door:unlocked-door'

module.exports = class TaleSystem
