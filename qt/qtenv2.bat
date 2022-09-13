@echo off
echo Setting up environment for Qt usage...
set tmp_qt_dir=%~dp0
set tmp_qt_dir=%tmp_qt_dir:~0,-1%

set PATH=%tmp_qt_dir%;%PATH%