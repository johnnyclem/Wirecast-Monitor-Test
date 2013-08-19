Wirecast-Monitor-0.1--alpha-
============================

Wirecast Monitor 0.1 (alpha)

Forked from  LearningLabDTU-hoeiriis

Wirecast provides a limited API through AppleScript's scripting bridge.  It's not well documented and has a few fundamental pieces that are missing in action compared to the equally archaic Win32 COM interop API for Win32 Wirecast.

Most notably, there is no way to query the Wirecast document, (or application) to check the current status for Broadcasting and Recording.

This sample project attempts to provide a way to monitor / check the status for broadcast/recording of Wirecast, using whatever means necessary.

To perform the available AppleScript commands in your Cocoa application, checkout my AppleScript -> Cocoa repo: https://github.com/johnnyclem/JCAppleScript
