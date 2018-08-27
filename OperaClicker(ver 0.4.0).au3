#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#comments-start
Версия 0.3.5(Alpha)
Новое в версии:
1) проверка на смерть
2) лечение
3) самоопределение режима игры
4) определение уровня персонажа

#comments-end

#include <UIAutomate.au3>


#comments-start
#comments-end
Func Start();запуск программы
Opt("WinTitleMatchMode", 2)
Global Const $OPERA = _Opera_Start()
Global $OPERACONTAINER = _UIA_FindAllElements($OPERA,"Name","Контейнер сторінки")[1]
EndFunc
Global $TIMEFLAG_G = ""
Global $TIMEFLAG_F = ""
Global $TIMEFLAG_T = ""
Global $P1 = "Зелье здоровья"
Global $P2 = "Зелье Силы"
Global $P3 = ""
Global $TIMEFLAG_P1 = ""
Global $TIMEFLAG_P2 = ""
Global $TIMEFLAG_P3 = ""
Global $cdp1 = -1
Global $cdp2 = -1
Global $cdp3 = -1
Global $CURRENTUSERMINHP = 0;
Global $currentlvl = 0;
Global $GROM = -1
Global $TIMEQUEST = 0
Global $INCAB = True
Global $CALL = 0

Start()
;Kach_Start($INCAB)
;Lvl3()
;Lvl4()
;Lvl5()
;Lvl6_8()
;Lvl8_10()
;Lvl10_12()

TakePotions()
Func _Opera_Start();запуск браузера
#comments-start
	Local $operwnd, $private
    ShellExecute("Opera.exe", "--force-renderer-accessibility", "C:\Program Files\Opera\")
    $operwnd = WinWaitActive("Opera", Null, 10)
    Sleep(2000)
    Send("^+n")
    Sleep(1000)
    WinClose($operwnd)
#comments-end
	Sleep(3000)
	$private = WinWaitActive("Opera", Null, 10)
    If Not $private Then Exit ConsoleWrite(" - Окно не найдено" & @LF)
    $oParent = _UIA_GetElementFromHandle($private)
    Return $oParent

	EndFunc
	Func OpenMT();открытие сайта игры

	$adresstype = _UIA_GetControlTypeElement($OPERA, "UIA_EditControlTypeId", "Поле адреси") ;Поле адреси
    _UIA_ElementMouseClick($adresstype)
    Sleep(1000)
    Send("m.vten.ru{ENTER}")
	Sleep(1000)
	Send("^-")
	$light_version = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Облегч","LegacyIAccessible.Name:",True,0)
	If (IsObj($light_version)) Then
	_UIA_ElementDoDefaultAction($light_version)
	Else
	Exit
	EndIf
Sleep(2000)

EndFunc   ;==>_OPERACONTAINER_Start

 Func Kach_Start($in_cabinet);прохождение игры до начала регистрации персонажа

If($in_cabinet) Then
Start_Play($in_cabinet)
FirstQuest()
SecondQuest()
LastQuest()
Else
OpenMT()
Start_Play($in_cabinet)
FirstQuest()
SecondQuest()
LastQuest()
EndIf

 EndFunc

 Func Start_Play($in_cabinet);начало игры

If($in_cabinet) Then
$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","кабинет","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","новую игру","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
Else


WaitFullLoad()
Beep(300,300)
$startbutton = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Начать","LegacyIAccessible.Name:",True,0)
_UIA_ElementDoDefaultAction($startbutton)
Beep(300,300)
EndIf

EndFunc

Func FirstQuest()
	WaitFullLoad()
$tavern = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Таверна","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($tavern)
	WaitFullLoad()
	$n = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Выследить","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($n)
DoQuest(0,"","")
EndFunc

Func SecondQuest()
$n = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","поиски","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($n)
DoQuest(0,"","")
EndFunc

Func LastQuest()

$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
		WaitFullLoad()
$n = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Тело","LegacyIAccessible.Description:",True,0)
	_UIA_ElementDoDefaultAction($n)
	WaitFullLoad()

	$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Снять","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()

	$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Рюкзак","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Надеть","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
	Sleep(300)
	WaitFullLoad()
Local $n2 = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Надеть","LegacyIAccessible.Name:",True)
	_UIA_ElementDoDefaultAction($n2)
	WaitFullLoad()
	$campaign = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
	$campaign = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","город","LegacyIAccessible.Name:",True)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
$campaign = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","аверна","LegacyIAccessible.Name:",True)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
$campaign = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Отправиться","LegacyIAccessible.Name:",True)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
DoQuest(0,"","")
StopJack()

ChooseWay(3,"m",1)

EndFunc

Func StopJack()
WaitFullLoad()
$stop = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Остановить","LegacyIAccessible.Name:",True)
_UIA_ElementDoDefaultAction($stop)
DoBattle(DetermineUserMode())
WaitFullLoad()
$end = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Очнуться","LegacyIAccessible.Name:",True,0)
_UIA_ElementDoDefaultAction($end)
EndFunc

Func ChooseWay($class,$gender,$way);выбор класса и т.д.

$choose = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Выбрать","LegacyIAccessible.Name:",True,0)
_UIA_ElementDoDefaultAction($choose)
Sleep(3000)
WaitFullLoad()
$adresstype = _UIA_WaitControlTypeElement($OPERA,"UIA_EditControlTypeId (0xC354)","Поле","LegacyIAccessible.Name:",True,4)
_UIA_ElementSetFocus($adresstype)
_UIA_ElementTextSetValue($adresstype,"http://m.vten.ru/user/customize?sex="&$gender&"&side="&$way&"&type="&$class)

Send("{ENTER}")
Sleep(500)
WaitFullLoad()
$create_hero = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Создать","LegacyIAccessible.Name:",True,0)
_UIA_ElementDoDefaultAction($create_hero)
WaitFullLoad()

EndFunc

Func Lvl3()
Sleep(2000)
Save(Not $INCAB)
Get_Amulet()
Upgrade_Amuletes()
Take_Reward()
DoTask(1,"Победи")
Take_Reward()

EndFunc

Func Lvl4()
$currentlvl = 4;
WaitFullLoad()
DoTask(0,"фолиант")
OpenBook()
Take_Reward()
DoTask(0,"волшебный")
ChangeItem("Волшебный Меч",True)
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","ород","LegacyIAccessible.Name:",True,0))
Take_Reward()
DoTask(1,"Победи")
Take_Reward()
WaitFullLoad()
DoTask(1,"Победи")
Take_Reward()

EndFunc

Func Lvl5()
$currentlvl = 5
Local Const $CurrentLvlQuestTime = 180000;
DoTask(2,"Собери")
$TIMEQUEST = $CurrentLvlQuestTime
DoDungeon("Святилище","Норма",False,False)
ChangeSet(3,0)
UpdateUserData()
$TIMEQUEST -= TimerDiff($TIMEFLAG_T)
If($TIMEQUEST > 0) Then
Sleep($TIMEQUEST)
Take_Reward()
Else
Take_Reward()
EndIf

EndFunc

Func Lvl6_8()
UpdateUserData()
$currentlvl = 6 
Local Const $CurrentLvlQuestTime = 180000;
$TIMEQUEST = $CurrentLvlQuestTime;
Local $num = 0;
Local $questname [2] = ["Расспроси","Поищи"];
ChangeSettings()
DoTask(2,$questname[$num])
$num+=1
DoQuest(1,"Боевое","караван")
DoQuest(1,"прогулка","Акиру")
UpdateTimeFlag("T")

Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$TIMEQUEST = $CurrentLvlQuestTime;
$num+=1;
EndIf
DisenchantAll()
UpdateTimeFlag("T")

Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf
DoTask(1,"Победи")
UpdateTimeFlag("T")

Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf
DoTask(1,"Победи")
UpdateTimeFlag("T")

Take_Reward()

While ($num < 2)

If($TIMEQUEST < 0) Then


Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
Else
Sleep($TimeQuest+500)
Take_Reward()
UpdateTimeFlag("T")
EndIf
WEnd
City()
UpdateUserData()

EndFunc

Func Lvl8_10()
UpdateUserData()
$currentlvl = 8
Local Const $CurrentLvlQuestTime = 180000;
$TIMEQUEST = $CurrentLvlQuestTime;
Local $num = 0;
Local $questname[2] = ["Проложи","провиант"];
DoTask(2,$questname[$num])
$num+=1
RenamePet()
UpdateTimeFlag("T")
Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then

Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf
DoTask(1,"Победи")
UpdateTimeFlag("T")
Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf
DoTask(1,"Победи")
UpdateTimeFlag("T")
Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf
DoTask(1,"Победи")
UpdateTimeFlag("T")
Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf
DoQuest(1,"пыль","Бангао")
UpdateTimeFlag("T")
Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf
DoQuest(1,"пыль","Найти")
UpdateTimeFlag("T")
Take_Reward()
If($TIMEQUEST < 0 And $num < 2) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
EndIf

While ($num < 2)
If($TIMEQUEST < 0) Then
Take_Reward();
DoTask(2,$questname[$num])
$num+=1;
$TIMEQUEST = $CurrentLvlQuestTime;
Else
Sleep($TimeQuest+500)
Take_Reward()
UpdateTimeFlag("T")
EndIf
WEnd
City()
$currentlvl = 10
EndFunc

Func Lvl10_12()
$currentlvl = 10
Local Const $CurrentLvlQuestTime = 180000;
$TIMEQUEST = $CurrentLvlQuestTime;

EndFunc
Func DoQuest($type,$name,$key_word)
;тип квеста,0 - квест обучающий, 1 - боевой квест(поиск квеста в таверне и его выполнение, выход в город), 2 - квест на сдачу ресурсов, 3 - особый квест(механика определяется согласно специальной библиотеки)

Select
    Case $type=0
	DoBattle(0)
	$continue = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Продолжить","LegacyIAccessible.Name:",True,6)
	If IsObj($continue) Then _UIA_ElementDoDefaultAction($continue)
	Case $type=1
	
	WaitFullLoad()
	$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Задания","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
	$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Таверна","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
    WaitFullLoad()
	SearchQuest($name,$key_word)
	DoBattle(DetermineUserMode())
	If(CheckDeath("Q",$type,$name,$key_word)) Then
	Return 0
	Else
	City()
	EndIf
	EndSelect
EndFunc

Func SearchQuest($name,$key_word)
Local $q = "sq";
$q = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$name,"LegacyIAccessible.Name:",True)
If(IsObj($q)) Then
_UIA_ElementDoDefaultAction($q)
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$key_word,"LegacyIAccessible.Name:",True))
WaitFullLoad()
Else

EndIf
EndFunc
Func ChangeSettings()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Настройки","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_ElementGetPreviousNext(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_TextControlTypeId (0xC364)","Пояс","LegacyIAccessible.Name:",True,0))[1])
WaitFullLoad()
City()
EndFunc

Func DoBattle($mode);0-режим новичка(просто атака),1-атака с громом, 2 - классовый режим(удары и гром, проверка на смерть, распитие зелий, начиная с версии 0.5.3)
Local $timetowait = 0
Local $continue = ""
Local $cond = True

    Select
    Case $mode=0
	While ($cond)
	Attack()
	$timetowait = Random(-1500,2500)
	Sleep(2500+$timetowait)
	WaitFullLoad()
	Local $cond1 = IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Добивать","LegacyIAccessible.Name:",True,(2/10)))
	Local $cond2 = IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Бить","LegacyIAccessible.Name:",True,(2/10)))
	Local $cond = $cond1 Or $cond2
	WEnd
    Case $mode=1
	While ($cond)
	UpdateTimeFlag("L")
	If($GROM <= 0) Then
	Lightning()
	Else
	Attack()
	EndIf
	$timetowait = Random(-1500,2500)+2000
	Sleep($timetowait)
	WaitFullLoad()
	Local $cond1 = IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Добивать","LegacyIAccessible.Name:",True,(2/10)))
	Local $cond2 = IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Бить","LegacyIAccessible.Name:",True,(2/10)))
	Local $cond = $cond1 Or $cond2
	WEnd
	Case $mode=2
	While($cond)
	CheckHp()
	UpdateTimeFlag("L")
	If($GROM <= 0) Then
	Lightning()
	Else
	Attack()
	EndIf
	$timetowait = Random(-1500,2500)+2000
	Sleep($timetowait)
	WaitFullLoad()
	Local $cond1 = IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Добивать","LegacyIAccessible.Name:",True,(2/10)))
	Local $cond2 = IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Бить","LegacyIAccessible.Name:",True,(2/10)))
	Local $cond = $cond1 Or $cond2
	WEnd
  EndSelect


EndFunc

Func Attack();стандартная атака

$attackclick = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Добивать","LegacyIAccessible.Name:",True,2)
If (Not(IsObj($attackclick))) Then
 _UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Бить","LegacyIAccessible.Name:",True,2))
Else
_UIA_ElementDoDefaultAction($attackclick)
EndIf
EndFunc

Func OpenBook()
WaitFullLoad()
Sleep(1000)
Local $books = _UIA_FindAllElements($OPERACONTAINER,"Name","Открыть книгу")
$b = Random(1,6,1)

_UIA_ElementDoDefaultAction($books[$b])
WaitFullLoad()
Sleep(2000)
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","ород","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
EndFunc

Func Lightning()
$lightning = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","ГМ","LegacyIAccessible.Name:",True,0)
_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_TextControlTypeId (0xC364)","сек","LegacyIAccessible.Name:",True,0)
_UIA_ElementDoDefaultAction($lightning)
$TIMEFLAG_G = TimerInit()
$GROM = 30000
EndFunc

Func Save($have_password);сохраняет персонажа(с присутствием или отсутствием пароля в случае созданния персонажа внутри кабинета)

Send("{F5}")
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Сохранить","LegacyIAccessible.Name:",True,0));UIA_EditControlTypeId (0xC354)
$nametype = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_EditControlTypeId (0xC354)","Имя","LegacyIAccessible.Name:",True,0)
_UIA_ElementSetFocus($nametype)
$name = GetDataFromFile();временный вариант
Send($name);вставляем ник
If $have_password Then
$passwordtype = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_EditControlTypeId (0xC354)","Пароль","LegacyIAccessible.Name:",True,0)
_UIA_ElementSetFocus($passwordtype)
Send("1234567890")
EndIf

_UIA_ElementMouseClick(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_ButtonControlTypeId (0xC350)","Сохранить","LegacyIAccessible.Name:",True,0))

EndFunc

Func Get_Amulet()
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","подар","LegacyIAccessible.Name:",True,0));ежедневный подарок
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Забрать","LegacyIAccessible.Name:",True,0));забрать
_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_TextControlTypeId (0xC364)","сек","LegacyIAccessible.Name:",True,0)
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","ород","LegacyIAccessible.Name:",True,0));В город
EndFunc

Func Upgrade_Amuletes()
DoTask(0,"Улучши")
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Амул","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
Upgrade_Amulet("Гром")
Upgrade_Amulet("Защита")
City()

EndFunc

Func Upgrade_Amulet($name);name - название амулета
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$name,"LegacyIAccessible.Name:",True,0))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Улучшить","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Амул","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
EndFunc
Func DoTask($mode,$key_word = "");0-открыть задание,1-победить какую-то хрень,2- задание на время, 3 - сварить мет, ой, то есть 2 зелья
Select
    Case $mode=0
	$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Задан","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
	_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$key_word,"LegacyIAccessible.Name:",True,0))
	WaitFullLoad()
	Case $mode=1
	WaitFullLoad()
	$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Задан","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
	WaitFullLoad()
	_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$key_word,"LegacyIAccessible.Name:",True,0))
	
	DoBattle(DetermineUserMode())
	WaitFullLoad()
	City()
	Case $mode=2
	WaitFullLoad()
	$campaign = _UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Задан","LegacyIAccessible.Name:",True,0)
	_UIA_ElementDoDefaultAction($campaign)
    WaitFullLoad()
	_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$key_word,"LegacyIAccessible.Name:",True,0))
	$TIMEFLAG_T = TimerInit()
	City()
	WaitFullLoad()
	EndSelect


EndFunc

Func UseForceAmuletGroup($mode);1-воин(по умолчанию),2-монах, 3 - маг
EndFunc

Func Take_Reward()
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Задания","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
While CheckReward()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","абрать","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
WEnd
City()
WaitFullLoad()
Return 1
EndFunc

Func WaitFullLoad()
_UIA_WaitControlTypeElement($OPERA,"UIA_ButtonControlTypeId (0xC350)","Перезавантажити","LegacyIAccessible.Name:",True,0)
EndFunc

Func CheckReward()
$flag = False

WaitFullLoad()
Local $testarray = _UIA_FindAllElements($OPERACONTAINER,"ControlType",50005)
For $in = 1 to $testarray[0]
;StringInStr("the string to search", "string", [0], [1], [1], [11])
#comments-start
string	Проверяемая строка.
substring	Подстрока для поиска.
casesense	[необязательный] Флаг установки чувствительности к регистру написания.
0 = (по умолчанию) не учитывать регистр, используется локальный язык
1 = учитывать регистр
2 = не учитывать регистр, используется основное / быстрое сравнение
occurrence	[необязательный] Номер искомого вхождения подстроки в строку. Используйте отрицательное значение параметра для поиска справа. По умолчанию 1 (поиск первого вхождения).
start	[необязательный] Начальная позиция поиска, отсчёт от 1.
count	[необязательный] Количество символов для поиска. Это ограничивает поиск на участке полной строки. См. примечания.
#comments-end
If(StringInStr(_UIA_ElementGetPropertyValue($testarray[$in],"Name"), "награду", 2) <> 0) Then
$flag = True
EndIf
Next
Return ($flag)

EndFunc

Func RenamePet()
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Питом","LegacyIAccessible.Name:",True))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Волк","LegacyIAccessible.Name:",True))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","имя","LegacyIAccessible.Name:",True))
WaitFullLoad()
$nametype = _UIA_ElementGetPreviousNext(_UIA_GetControlTypeElement($OPERA,50020,"(имя должно быть от 3-х до 12-ти русских или английских букв)","Name",True))[1]
_UIA_ElementSetFocus($nametype)
Send("Мой Питомец")

Sleep(1000)
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_ButtonControlTypeId (0xC350)","имя","LegacyIAccessible.Name:",True))
WaitFullLoad()
City()
EndFunc

Func DoDungeon($name,$difficulty ,$IsMultiStep,$autosearch);прохождение подземелия самостоятельно или через автопоиск,в зависимости от количества этапов, возвращает награду в виде строки с разделителями
If $isMultiStep Then


Else
If $autosearch Then

Else
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Подземелья","LegacyIAccessible.Name:",True))
WaitFullLoad()
If (IsObj(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","30","LegacyIAccessible.Name:",True))) Then
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","До","LegacyIAccessible.Name:",True))
EndIf
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$name,"LegacyIAccessible.Name:",True))
WaitFullLoad()
If (IsObj(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$difficulty,"LegacyIAccessible.Name:",True))) Then
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$difficulty,"LegacyIAccessible.Name:",True))
EndIf
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Войти","LegacyIAccessible.Name:",True))
 WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Начать","LegacyIAccessible.Name:",True))
 WaitFullLoad()

DoBattle(DetermineUserMode())
_UIA_WaitControlTypeElement($OPERA,"UIA_TextControlTypeId (0xC364)","Пройдено","LegacyIAccessible.Name:",True,0)
City()


EndIf
EndIf
EndFunc

Func DisenchantAll();Разобрать все вещи
	WaitFullLoad()
	_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Рюкзак","LegacyIAccessible.Name:",True,0))
	WaitFullLoad()
		While IsObj(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Разобрать","LegacyIAccessible.Name:",True))
		_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Разобрать","LegacyIAccessible.Name:",True))
		WaitFullLoad()
		_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Да","LegacyIAccessible.Name:",True))
		WaitFullLoad()
		WEnd
City()
EndFunc

Func ChangeSet($mode,$type_of_set);Смена одежды , в зависимости от требований.mode - класс персонажа , $type_of_set - тип набора;1-маг , 2 - монах, 3-воин.0 - рунический набор
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Рюкзак","LegacyIAccessible.Name:",True,0))
Select
	Case $mode=1
	
	Case $mode=2
	
	Case $mode=3
		Select
			Case $type_of_set=0
			WaitFullLoad()
			While CheckItemForType("Руническ")
			ChangeItem("Руническ",False)
			WEnd
			Case $type_of_set=1
	
			Case $type_of_set=2
	
	
	
	EndSelect


	
	
	EndSelect
City()
EndFunc

Func ChangeItem($name,$full);
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$name,"LegacyIAccessible.Name:",Not($full),0))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Надеть","LegacyIAccessible.Name:",True,0))
 WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Рюкзак","LegacyIAccessible.Name:",True,0))
EndFunc
Func CheckItemForType($name)
$flag = False

WaitFullLoad()
Local $testarray = _UIA_FindAllElements($OPERACONTAINER,"ControlType",50005)
For $in = 1 to $testarray[0]
;StringInStr("the string to search", "string", 0, 1, 1, 11)
If(StringInStr(_UIA_ElementGetPropertyValue($testarray[$in],"Name"), $name, 2) <> 0) Then
$flag = True
EndIf
Next
Return ($flag)
EndFunc

Func UsePotion($name)
$pot = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)",$name,"LegacyIAccessible.Name:",True)
If(IsObj($pot)) Then
_UIA_ElementDoDefaultAction($pot)
Return True;
Else;
Return False;
EndIf
EndFunc

Func UseStone(); накидывает камень на самую лучшую вещь на персонажа(из зачарованного набора)


EndFunc

Func City()
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","ород","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
EndFunc

Func UpdateTimeFlag($t)
Switch $t
Case "L"
$GROM -= TimerDiff($TIMEFLAG_G)
Case "T"
$TIMEQUEST -= TimerDiff($TIMEFLAG_T)
$TIMEFLAG_T = TimerInit()
Case "P1"
$cdp1 -= TimerDiff($TIMEFLAG_P1)
$TIMEFLAG_P1 = TimerInit()
Case "P2"
$cdp2 -= TimerDiff($TIMEFLAG_P2)
$TIMEFLAG_P2 = TimerInit()
Case "P3"
$cdp3 -= TimerDiff($TIMEFLAG_P3)
$TIMEFLAG_P3 = TimerInit()
Case "X"
MsgBox(0,"","ЧХ")
Case Else
MsgBox(0,"","Всё хуйня, давай по новой")
EndSwitch
EndFunc

Func UpdateUserData()
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True,0))
WaitFullLoad()
$vitality = _UIA_ElementGetPropertyValue(_UIA_ElementGetPreviousNext(_UIA_ElementGetPreviousNext(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_TextControlTypeId (0xC364)","Живучест","LegacyIAccessible.Name:",True))[1])[1],"Name");
$CURRENTUSERMINHP = $vitality *3.5;
City()
EndFunc
Func DetermineUserMode()
Switch $currentlvl
Case 0 To 3
Return 0
Case 4 To 7
Return 1
Case 8 To 10
Return 2
Case Else
Return 3
EndSwitch
EndFunc

Func SetAmuletes($mode)


EndFunc

Func CheckHp()
WaitFullLoad()
$hp = _UIA_ElementGetPropertyValue( _UIA_ElementGetPreviousNext(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_ImageControlTypeId (0xC356)","хп","LegacyIAccessible.Name:",False))[1],"Name")
UpdateTimeFlag("P1")
UpdateTimeFlag("P2")
UpdateTimeFlag("P3")
If( $hp < $CURRENTUSERMINHP ) Then
MsgBox(0,"","1if")
If(UsePotion($P1) And $cdp1 < 0) Then
$TIMEFLAG_P1 = TimerInit()
$cdp1 = 60000
If ($hp > $CURRENTUSERMINHP) Then
Return 1;
Else
CheckHp()
EndIf
Else
$P1 = "";
If(UsePotion($P2) And $cdp2 < 0) Then
$TIMEFLAG_P2 = TimerInit()
$cdp2 = 60000
If ($hp > $CURRENTUSERMINHP) Then
Return 1;
Else
CheckHp()
EndIf
Else 
$P2 = ""
If(UsePotion($P3) And $cdp3 < 0) Then
$TIMEFLAG_P1 = TimerInit()
$cdp3 = 60000
If ($hp > $CURRENTUSERMINHP) Then
Return 1;
Else
CheckHp
EndIf
Else
$P3 = ""
EndIf

EndIf
EndIf
EndIf

EndFunc

Func TakePotions()
$P1=''
$P2=''
$P3=''
WaitFullLoad()
Const $max = 3 
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True))
WaitFullLoad()
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Пояс","LegacyIAccessible.Name:",True))
WaitFullLoad()
Sleep(1000)
$belt = _UIA_GetControlTypeElement($OPERACONTAINER,"UIA_TextControlTypeId (0xC364)","Пояс","LegacyIAccessible.Name:",True)

$s = _UIA_ElementGetPropertyValue($belt,"LegacyIAccessible.Name")
$test = StringSplit($s," ")[2]
$potions_num = StringSplit($test,"/")[1]
$block = ""
Local $li = _UIA_ElementGetParent($belt);
Local $x = 1
While(Not(_UIA_ElementGetPropertyValue($li,"Name") == "Ларец"));анализ зелий на поясе и создания блокирующего списка
$x = _UIA_GetControlTypeElement($li,"UIA_TextControlTypeId (0xC364)","(","LegacyIAccessible.Name:",True)
If (IsObj($x)) Then
EndIf
WEnd
$mystr = ""

Return 1;завершение работы функции
EndFunc

Func UpdatePotionName($name)
If($P1 <> "") Then
$P1=$name
Return 1;
Else

If($P2 <> "") Then
$P2=$name
Return 1;
Else

If($P3 <> "") Then
$P1=$name
Return 1;

EndIf

EndIf

EndIf

EndFunc

Func CheckDeath($place,$mode,$specvar,$addittional_parameter)
WaitFullLoad()
Switch $place
Case "Q"
If(IsObj(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Покинуть","LegacyIAccessible.Name:",True))) Then
$goback =_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Покинуть","LegacyIAccessible.Name:",True)
_UIA_ElementDoDefaultAction($goback)
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True))
City()
DoQuest($mode,$specvar,$addittional_parameter)
Return True;
EndIf
If(IsObj(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_TextControlTypeId (0xC364)","Кладбище","LegacyIAccessible.Name:",True))) Then
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Персонаж","LegacyIAccessible.Name:",True))
City()
DoQuest($mode,$specvar,$addittional_parameter)
Return True;
EndIf
;UIA_ImageControlTypeId (0xC356)

If(IsObj(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_TextControlTypeId (0xC364)","Ты не устоял в этой","LegacyIAccessible.Name:",True))) Then
_UIA_ElementDoDefaultAction(_UIA_GetControlTypeElement($OPERACONTAINER,"UIA_HyperlinkControlTypeId (0xC355)","Рюкзак","LegacyIAccessible.Name:",True))
City()
DoQuest($mode,$specvar,$addittional_parameter)
Return True;
EndIf

EndSwitch
Return False
EndFunc

Func GetDataFromFile()
$f = FileOpen("name.txt")
$s = FileReadLine($f)
If (@error = -1) Then
Return MsgBox(0,"","Ошибка Чтения Файла")
Else
Return $s;
EndIf
EndFunc

#comments-start
Func DoControlAction($element_name,$typeelement,$control_element,$control_type)
$CALL+=1
WaitFullLoad()
MsgBox(0,"","Load")
If($CALL>5) Then
Return MsgBox(0,"","Fatal Error on element"&$element_name)
EndIf
MsgBox(0,"","Next")
_UIA_ElementDoDefaultAction(_UIA_WaitControlTypeElement($OPERACONTAINER,$typeelement,$element_name,"LegacyIAccessible.Name:",True,0))
MsgBox(0,"","Act")
If ($element_name == $control_element) And ($typeelement = $control_type) Then
MsgBox(0,"","eq")
If (Not IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,$typeelement,$element_name,"LegacyIAccessible.Name:",True,(3/10)))) Then
MsgBox(0,"","true")
$CALL = 0
MsgBox(0,"","ret")
Return "Success"
Else
MsgBox(0,"","False")
DoControlAction($element_name,$typeelement,$control_element,$control_type)
EndIf
Else
If (Not IsObj(_UIA_WaitControlTypeElement($OPERACONTAINER,$typeelement,$element_name,"LegacyIAccessible.Name:",True,(3/10)))) Then
DoControlAction($element_name,$typeelement,$control_element,$control_type)
Else
$CALL = 0
Return "Success"

EndIf
EndIf
EndFunc
#comments-end