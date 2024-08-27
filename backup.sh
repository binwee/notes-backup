#!/bin/bash
NOTES_HOME=/data/notes
cd $NOTES_HOME
git add .
git commit -m 'notes-backup'
git push origin master --force
