#include-once
#include <UIAConstants.au3>

; ============================================================================================
; Название      : UIAutomate.au3
; Версия AutoIt : 3.3.10.0 +
; Версия UDF    : 1.8
; Описание      : Набор функций для работы с элементами GUI посредством API UIAutomation
; Автор         : InnI
; ============================================================================================

; #ГЛОБАЛЬНЫЕ_ПЕРЕМЕННЫЕ# ====================================================================
Global $UIA_ConsoleWriteError = 1 ; Вывод описания ошибок в консоль
Global $UIA_DefaultWaitTime   = 5 ; Время ожидания по умолчанию в секундах
Global $UIA_ElementVersion    = 1 ; Версия элемента: 0-авто; 1-WIN_7 и ниже; 2-WIN_8; 3-WIN_81; 4,5-WIN_10; 6,7-WIN_10(1703)
; ============================================================================================

; #ФУНКЦИИ# ==================================================================================
; _UIA_CreateLogicalCondition        Создаёт логическое условие на основе заданных условий
; _UIA_CreatePropertyCondition       Создаёт условие на основе свойства и его значения
; _UIA_ElementDoDefaultAction        Выполнение элементом действия по умолчанию
; _UIA_ElementFindInArray            Находит элемент, соответствующий заданному свойству и его значению
; _UIA_ElementGetBoundingRectangle   Определяет прямоугольную область, ограничивающую элемент
; _UIA_ElementGetFirstLastChild      Находит первый и последний дочерние элементы (объекты) указанного элемента
; _UIA_ElementGetParent              Определяет родительский элемент (объект) указанного элемента
; _UIA_ElementGetPreviousNext        Находит предыдущий и следующий элементы (объекты) того же уровня
; _UIA_ElementGetPropertyValue       Определяет значение заданного свойства элемента
; _UIA_ElementMouseClick             Выполняет клик мыши по элементу
; _UIA_ElementScrollIntoView         Прокручивает элемент в область видимости
; _UIA_ElementSetFocus               Устанавливает элементу фокус ввода
; _UIA_ElementTextSetValue           Устанавливает значение (текст) в текстовый элемент
; _UIA_FindAllElements               Находит все элементы, соответствующие заданному свойству и его значению
; _UIA_FindAllElementsEx             Находит все элементы, соответствующие условию поиска
; _UIA_FindElementsInArray           Находит все элементы, соответствующие заданному свойству и его значению
; _UIA_GetControlTypeElement         Находит элемент (объект) указанного типа с заданным свойством и значением
; _UIA_GetElementFromCondition       Находит элемент (объект) на основе заданного условия
; _UIA_GetElementFromFocus           Создаёт элемент (объект) на основе фокуса ввода
; _UIA_GetElementFromHandle          Создаёт элемент (объект) на основе дескриптора
; _UIA_GetElementFromPoint           Создаёт элемент (объект) на основе экранных координат
; _UIA_ObjectCreate                  Создаёт объект UIAutomation
; _UIA_WaitControlTypeElement        Ожидает элемент (объект) указанного типа с заданным свойством и значением
; _UIA_WaitElementFromCondition      Ожидает элемент (объект) на основе заданного условия
; ============================================================================================

; #ДЛЯ_ВНУТРЕННЕГО_ИСПОЛЬЗОВАНИЯ# ============================================================
; __UIA_ConsoleWriteError
; __UIA_CreateElement
; __UIA_GetPropIdFromStr
; __UIA_GetTypeIdFromStr
; ============================================================================================

; ============================================================================================
; Имя функции : _UIA_CreateLogicalCondition
; Описание    : Создаёт логическое условие на основе заданных условий
; Синтаксис   : _UIA_CreateLogicalCondition($oCondition1[, $sOperator = "NOT"[, $oCondition2 = 0]])
; Параметры   : $oCondition1 - первое условие
;             : $sOperator   - логический оператор (строка)
;             :              "NOT" - логическое НЕ (по умолчанию)
;             :              "AND" - логическое И
;             :              "OR"  - логическое ИЛИ
;             : $oCondition2 - второе условие
; Возвращает  : Успех   - условие
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первое условие не определено
;             :         @error = 2 - ошибка создания объекта UIAutomation
;             :         @error = 3 - второе условие не определено
;             :         @error = 4 - ошибка создания условия
;             :         @error = 5 - неизвестный условный оператор
; Автор       : InnI
; Примечание  : При использовании оператора "NOT" второе условие игнорируется
; ============================================================================================
Func _UIA_CreateLogicalCondition($oCondition1, $sOperator = "NOT", $oCondition2 = 0)
  If Not IsObj($oCondition1) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : первое условие не определено"), 0)
  Local $pCondition, $oCondition, $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : ошибка создания объекта UIAutomation"), 0)
  Switch $sOperator
    Case "NOT"
      $oUIAutomation.CreateNotCondition($oCondition1, $pCondition)
      $oCondition = ObjCreateInterface($pCondition, $sIID_IUIAutomationNotCondition, $dtagIUIAutomationNotCondition)
      If Not IsObj($oCondition) Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : ошибка создания условия"), 0)
    Case "AND"
      If Not IsObj($oCondition2) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : второе условие не определено"), 0)
      $oUIAutomation.CreateAndCondition($oCondition1, $oCondition2, $pCondition)
      $oCondition = ObjCreateInterface($pCondition, $sIID_IUIAutomationAndCondition, $dtagIUIAutomationAndCondition)
      If Not IsObj($oCondition) Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : ошибка создания условия"), 0)
    Case "OR"
      If Not IsObj($oCondition2) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : второе условие не определено"), 0)
      $oUIAutomation.CreateOrCondition($oCondition1, $oCondition2, $pCondition)
      $oCondition = ObjCreateInterface($pCondition, $sIID_IUIAutomationOrCondition, $dtagIUIAutomationOrCondition)
      If Not IsObj($oCondition) Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : ошибка создания условия"), 0)
    Case Else
      Return SetError(5, __UIA_ConsoleWriteError("_UIA_CreateLogicalCondition : неизвестный условный оператор (" & $sOperator & ")"), 0)
  EndSwitch
  Return $oCondition
EndFunc ; _UIA_CreateLogicalCondition

; ============================================================================================
; Имя функции : _UIA_CreatePropertyCondition
; Описание    : Создаёт условие на основе свойства и его значения
; Синтаксис   : _UIA_CreatePropertyCondition($vProperty, $vPropertyValue)
; Параметры   : $vProperty      - свойство элемента
;             : $vPropertyValue - значение свойства элемента
; Возвращает  : Успех   - условие
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - ошибка создания объекта UIAutomation
;             :         @error = 2 - ошибка преобразования свойства
;             :         @error = 3 - ошибка создания условия (см. примечание о типизации)
; Автор       : InnI
; Примечание  : Название свойства можно скопировать из левой части списка утилиты Inspect
;             : Значение свойства можно скопировать из правой части списка утилиты Inspect
;             : Значения свойств типизированы. Например, для свойства "IsEnabled" нужно указывать значение True, а не 1 и не "True"
; ============================================================================================
Func _UIA_CreatePropertyCondition($vProperty, $vPropertyValue)
  Local $pCondition, $oCondition, $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_CreatePropertyCondition : ошибка создания объекта UIAutomation"), 0)
  $vProperty = __UIA_GetPropIdFromStr($vProperty, "_UIA_CreatePropertyCondition")
  If $vProperty = -1 Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_CreatePropertyCondition : ошибка преобразования свойства"), 0)
  $oUIAutomation.CreatePropertyCondition($vProperty, $vPropertyValue, $pCondition)
  $oCondition = ObjCreateInterface($pCondition, $sIID_IUIAutomationPropertyCondition, $dtagIUIAutomationPropertyCondition)
  If Not IsObj($oCondition) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_CreatePropertyCondition : ошибка создания условия (см. примечание о типизации)"), 0)
  Return $oCondition
EndFunc ; _UIA_CreatePropertyCondition

; ============================================================================================
; Имя функции : _UIA_ElementDoDefaultAction
; Описание    : Выполнение элементом действия по умолчанию
; Синтаксис   : _UIA_ElementDoDefaultAction($oElement)
; Параметры   : $oElement - элемент (объект)
; Возвращает  : Успех   - 1
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является объектом
;             :         @error = 2 - ошибка создания объекта на основе шаблона LegacyIAccessible
;             :         @error = 3 - ошибка выполнения метода
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func _UIA_ElementDoDefaultAction($oElement)
  If Not IsObj($oElement) Then 
  Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementDoDefaultAction : параметр не является объектом"), 0)
  EndIf
  Local $pIAccess, $oIAccess
  $oElement.GetCurrentPattern($UIA_LegacyIAccessiblePatternId, $pIAccess)
  $oIAccess = ObjCreateInterface($pIAccess, $sIID_IUIAutomationLegacyIAccessiblePattern, $dtagIUIAutomationLegacyIAccessiblePattern)
  If Not IsObj($oIAccess) Then 
  MsgBox(0,"","error creation")  
  Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementDoDefaultAction : ошибка создания объекта на основе шаблона LegacyIAccessible"), 0)
  EndIf
  Local $iErrorCode = $oIAccess.DoDefaultAction()
  If $iErrorCode Then
MsgBox(0,"","_UIA_ElementDoDefaultAction : ошибка выполнения метода (0x" & Hex($iErrorCode)&")")
 Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementDoDefaultAction : ошибка выполнения метода (0x" & Hex($iErrorCode) & ")"), 0)
EndIf 
  Return 1
EndFunc ; _UIA_ElementDoDefaultAction

; ============================================================================================
; Имя функции : _UIA_ElementFindInArray
; Описание    : Находит элемент, соответствующий заданному свойству и его значению
; Синтаксис   : _UIA_ElementFindInArray(Const ByRef $aElements, $vProperty, $vPropertyValue[, $fInStr = False[, $iStartIndex = 1[, $fToEnd = True]]])
; Параметры   : $aElements      - массив элементов (объектов)
;             : $vProperty      - свойство искомого элемента
;             : $vPropertyValue - значение свойства искомого элемента
;             : $fInStr         - полное совпадение значения свойства (по умолчанию) или частичное
;             : $iStartIndex    - индекс начала поиска (по умолчанию 1)
;             : $fToEnd         - направление поиска: в конец массива (по умолчанию) или в начало массива
; Возвращает  : Успех   - индекс элемента (объекта) в исходном массиве
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является массивом
;             :         @error = 2 - пустой массив
;             :         @error = 3 - многомерный массив
;             :         @error = 4 - элемент массива [0] не соответствует количеству остальных элементов
;             :         @error = 5 - массив не содержит элементов
;             :         @error = 6 - элемент массива [индекс] не является объектом
;             :         @error = 7 - ошибка преобразования свойства
;             :         @error = 8 - некорректный индекс начала поиска
; Автор       : InnI
; Примечание  : Элемент массива с нулевым индексом должен содержать количество объектов
;             : Название свойства можно скопировать из левой части списка утилиты Inspect
;             : Значение свойства можно скопировать из правой части списка утилиты Inspect
; ============================================================================================
Func _UIA_ElementFindInArray(Const ByRef $aElements, $vProperty, $vPropertyValue, $fInStr = False, $iStartIndex = 1, $fToEnd = True)
  If Not IsArray($aElements) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : первый параметр не является массивом"), 0)
  If Not UBound($aElements) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : пустой массив"), 0)
  If UBound($aElements, 0) > 1 Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : многомерный массив"), 0)
  If $aElements[0] <> UBound($aElements) - 1 Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : элемент массива [0] не соответствует количеству остальных элементов"), 0)
  If Not $aElements[0] Then Return SetError(5, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : массив не содержит элементов"), 0)
  For $i = 1 To $aElements[0]
    If Not IsObj($aElements[$i]) Then Return SetError(6, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : элемент массива [" & $i & "] не является объектом"), 0)
  Next
  $vProperty = __UIA_GetPropIdFromStr($vProperty, "_UIA_ElementFindInArray")
  If $vProperty = -1 Then Return SetError(7, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : ошибка преобразования свойства"), 0)
  $iStartIndex = Int($iStartIndex)
  If $iStartIndex < 1 Or $iStartIndex > $aElements[0] Then Return SetError(8, __UIA_ConsoleWriteError("_UIA_ElementFindInArray : некорректный индекс начала поиска"), 0)
  Local $vValue, $iEndIndex = $aElements[0], $iStep = 1
  If Not $fToEnd Then
    $iEndIndex = 1
    $iStep = -1
  EndIf
  For $i = $iStartIndex To $iEndIndex Step $iStep
    $aElements[$i].GetCurrentPropertyValue($vProperty, $vValue)
    If $fInStr Then
      If StringInStr($vValue, $vPropertyValue) Then Return $i
    Else
      If $vPropertyValue = $vValue Then Return $i
    EndIf
    $vValue = 0
  Next
  Return 0
EndFunc ; _UIA_ElementFindInArray

; ============================================================================================
; Имя функции : _UIA_ElementGetBoundingRectangle
; Описание    : Определяет прямоугольную область, ограничивающую элемент
; Синтаксис   : _UIA_ElementGetBoundingRectangle($oElement)
; Параметры   : $oElement - элемент (объект)
; Возвращает  : Успех   - массив
;             :         $aArray[0] - X координата верхнего левого угла элемента
;             :         $aArray[1] - Y координата верхнего левого угла элемента
;             :         $aArray[2] - X координата нижнего правого угла элемента
;             :         $aArray[3] - Y координата нижнего правого угла элемента
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является объектом
;             :         @error = 2 - ошибка создания массива координат
; Автор       : InnI
; Примечание  : Координаты прямоугольника - экранные
; ============================================================================================
Func _UIA_ElementGetBoundingRectangle($oElement)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementGetBoundingRectangle : параметр не является объектом"), 0)
  Local $tRect = DllStructCreate("long Left;long Top;long Right;long Bottom")
  $oElement.CurrentBoundingRectangle($tRect)
  Local $aRect[4] = [$tRect.Left, $tRect.Top, $tRect.Right, $tRect.Bottom]
  $tRect = 0
  If Not IsArray($aRect) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementGetBoundingRectangle : ошибка создания массива координат"), 0)
  Return $aRect
EndFunc ; _UIA_ElementGetBoundingRectangle

; ============================================================================================
; Имя функции : _UIA_ElementGetFirstLastChild
; Описание    : Находит первый и последний дочерние элементы (объекты) указанного элемента
; Синтаксис   : _UIA_ElementGetFirstLastChild($oElement)
; Параметры   : $oElement - элемент (объект)
; Возвращает  : Успех   - массив
;             :         $aArray[0] - первый дочерний элемент (объект)
;             :         $aArray[1] - последний дочерний элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является объектом
;             :         @error = 2 - ошибка создания объекта UIAutomation
;             :         @error = 3 - ошибка создания объекта дерева
; Автор       : InnI
; Примечание  : Если первый/последний элемент отсутствует, то соответствующим элементом массива будет НЕ объект
; ============================================================================================
Func _UIA_ElementGetFirstLastChild($oElement)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementGetFirstLastChild : параметр не является объектом"), 0)
  Local $aFirstLast[2], $pFirstLast, $pRawWalker, $oRawWalker, $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementGetFirstLastChild : ошибка создания объекта UIAutomation"), 0)
  $oUIAutomation.RawViewWalker($pRawWalker)
  $oRawWalker = ObjCreateInterface($pRawWalker, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
  If Not IsObj($oRawWalker) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementGetFirstLastChild : ошибка создания объекта дерева"), 0)
  $oRawWalker.GetFirstChildElement($oElement, $pFirstLast)
  $aFirstLast[0] = __UIA_CreateElement($pFirstLast)
  $pFirstLast = 0
  $oRawWalker.GetLastChildElement($oElement, $pFirstLast)
  $aFirstLast[1] = __UIA_CreateElement($pFirstLast)
  $pFirstLast = 0
  Return $aFirstLast
EndFunc ; _UIA_ElementGetFirstLastChild

; ============================================================================================
; Имя функции : _UIA_ElementGetParent
; Описание    : Определяет родительский элемент (объект) указанного элемента
; Синтаксис   : _UIA_ElementGetParent($oElement)
; Параметры   : $oElement - элемент (объект)
; Возвращает  : Успех   - родительский элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является объектом
;             :         @error = 2 - ошибка создания объекта UIAutomation
;             :         @error = 3 - ошибка создания объекта дерева
; Автор       : InnI
; Примечание  : Если родительский элемент отсутствует, то функция вернёт НЕ объект
; ============================================================================================
Func _UIA_ElementGetParent($oElement)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementGetParent : параметр не является объектом"), 0)
  Local $pParent, $pRawWalker, $oRawWalker, $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementGetParent : ошибка создания объекта UIAutomation"), 0)
  $oUIAutomation.RawViewWalker($pRawWalker)
  $oRawWalker = ObjCreateInterface($pRawWalker, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
  If Not IsObj($oRawWalker) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementGetParent : ошибка создания объекта дерева"), 0)
  $oRawWalker.GetParentElement($oElement, $pParent)
  Return __UIA_CreateElement($pParent)
EndFunc ; _UIA_ElementGetParent

; ============================================================================================
; Имя функции : _UIA_ElementGetPreviousNext
; Описание    : Находит предыдущий и следующий элементы (объекты) того же уровня
; Синтаксис   : _UIA_ElementGetPreviousNext($oElement)
; Параметры   : $oElement - элемент (объект)
; Возвращает  : Успех   - массив
;             :         $aArray[0] - предыдущий элемент (объект)
;             :         $aArray[1] - следующий элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является объектом
;             :         @error = 2 - ошибка создания объекта UIAutomation
;             :         @error = 3 - ошибка создания объекта дерева
; Автор       : InnI
; Примечание  : Если предыдущий/следующий элемент отсутствует, то соответствующим элементом массива будет НЕ объект
;             : Не находит собственного родителя в качестве предыдущего и чужого родителя в качестве следующего
; ============================================================================================
Func _UIA_ElementGetPreviousNext($oElement)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementGetPreviousNext : параметр не является объектом"), 0)
  Local $aPrevNext[2], $pPrevNext, $pRawWalker, $oRawWalker, $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementGetPreviousNext : ошибка создания объекта UIAutomation"), 0)
  $oUIAutomation.RawViewWalker($pRawWalker)
  $oRawWalker = ObjCreateInterface($pRawWalker, $sIID_IUIAutomationTreeWalker, $dtagIUIAutomationTreeWalker)
  If Not IsObj($oRawWalker) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementGetPreviousNext : ошибка создания объекта дерева"), 0)
  $oRawWalker.GetPreviousSiblingElement($oElement, $pPrevNext)
  $aPrevNext[0] = __UIA_CreateElement($pPrevNext)
  $pPrevNext = 0
  $oRawWalker.GetNextSiblingElement($oElement, $pPrevNext)
  $aPrevNext[1] = __UIA_CreateElement($pPrevNext)
  $pPrevNext = 0
  Return $aPrevNext
EndFunc ; _UIA_ElementGetPreviousNext

; ============================================================================================
; Имя функции : _UIA_ElementGetPropertyValue
; Описание    : Определяет значение заданного свойства элемента
; Синтаксис   : _UIA_ElementGetPropertyValue($oElement, $vProperty)
; Параметры   : $oElement  - элемент (объект)
;             : $vProperty - свойство, значение которого нужно получить
; Возвращает  : Успех   - значение заданного свойства
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - ошибка преобразования свойства
;             :         @error = 3 - ошибка выполнения метода
; Автор       : InnI
; Примечание  : Название свойства можно скопировать из левой части списка утилиты Inspect
; ============================================================================================
Func _UIA_ElementGetPropertyValue($oElement, $vProperty)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementGetPropertyValue : первый параметр не является объектом"), 0)
  $vProperty = __UIA_GetPropIdFromStr($vProperty, "_UIA_ElementGetPropertyValue")
  If $vProperty = -1 Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementGetPropertyValue : ошибка преобразования свойства"), 0)
  Local $vValue, $iErrorCode = $oElement.GetCurrentPropertyValue($vProperty, $vValue)
  If $iErrorCode Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementGetPropertyValue : ошибка выполнения метода (0x" & Hex($iErrorCode) & ")"), 0)
  Return $vValue
EndFunc ; _UIA_ElementGetPropertyValue

; ============================================================================================
; Имя функции : _UIA_ElementMouseClick
; Описание    : Выполняет клик мыши по элементу
; Синтаксис   : _UIA_ElementMouseClick($oElement[, $sButton = ""[, $iX = Default[, $iY = Default[, $iClicks = 1[, $fSetFocus = True]]]]])
; Параметры   : $oElement - элемент (объект)
;             : $sButton  - кнопка мыши (по умолчанию левая)
;             : $iX       - X координата клика (по умолчанию середина ширины элемента)
;             : $iY       - Y координата клика (по умолчанию середина высоты элемента)
;             : $iClicks  - количество кликов (по умолчанию 1)
;             : $SetFocus - активация элемента перед кликом (по умолчанию True)
; Возвращает  : Успех   - 1
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - ошибка создания массива координат прямоугольной области
;             :         @error = 3 - координаты клика выходят за пределы элемента
;             :         @error = 4 - ошибка выполнения функции MouseClick
; Автор       : InnI
; Примечание  : Используются экранные координаты относительно левого верхнего угла элемента
; ============================================================================================
Func _UIA_ElementMouseClick($oElement, $sButton = "", $iX = Default, $iY = Default, $iClicks = 1, $fSetFocus = True)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementMouseClick : первый параметр не является объектом"), 0)
  If $fSetFocus Then $oElement.SetFocus()
  Local $aRect = _UIA_ElementGetBoundingRectangle($oElement)
  If Not IsArray($aRect) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementMouseClick : ошибка создания массива координат прямоугольной области"), 0)
  If $iX = Default Then $iX = ($aRect[2] - $aRect[0]) / 2
  If $iY = Default Then $iY = ($aRect[3] - $aRect[1]) / 2
  If $iX < 0 Or $iY < 0 Or $iX >= $aRect[2] - $aRect[0] Or $iY >= $aRect[3] - $aRect[1] Then  Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementMouseClick : координаты клика выходят за пределы элемента"), 0)
  Local $iMode = Opt("MouseCoordMode", 1)
  Local $iResult = MouseClick($sButton, $aRect[0] + $iX, $aRect[1] + $iY, $iClicks, 0)
  Opt("MouseCoordMode", $iMode)
  If Not $iResult Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_ElementMouseClick : ошибка выполнения функции MouseClick"), 0)
  Return 1
EndFunc ; _UIA_ElementMouseClick

; ============================================================================================
; Имя функции : _UIA_ElementScrollIntoView
; Описание    : Прокручивает элемент в область видимости
; Синтаксис   : _UIA_ElementScrollIntoView($oElement)
; Параметры   : $oElement - элемент (объект)
; Возвращает  : Успех   - 1
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является объектом
;             :         @error = 2 - ошибка создания объекта на основе шаблона ScrollItem
;             :         @error = 3 - ошибка выполнения метода
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func _UIA_ElementScrollIntoView($oElement)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementScrollIntoView : параметр не является объектом"), 0)
  Local $pScrollItem, $oScrollItem
  $oElement.GetCurrentPattern($UIA_ScrollItemPatternId, $pScrollItem)
  $oScrollItem = ObjCreateInterface($pScrollItem, $sIID_IUIAutomationScrollItemPattern, $dtagIUIAutomationScrollItemPattern)
  If Not IsObj($oScrollItem) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementScrollIntoView : ошибка создания объекта на основе шаблона ScrollItem"), 0)
  Local $iErrorCode = $oScrollItem.ScrollIntoView()
  If $iErrorCode Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementScrollIntoView : ошибка выполнения метода (0x" & Hex($iErrorCode) & ")"), 0)
  Return 1
EndFunc ; _UIA_ElementScrollIntoView

; ============================================================================================
; Имя функции : _UIA_ElementSetFocus
; Описание    : Устанавливает элементу фокус ввода
; Синтаксис   : _UIA_ElementSetFocus($oElement)
; Параметры   : $oElement - элемент (объект)
; Возвращает  : Успех   - 1
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является объектом
;             :         @error = 2 - ошибка выполнения метода
; Автор       : InnI
; Примечание  : Будет активировано окно, содержащее элемент
; ============================================================================================
Func _UIA_ElementSetFocus($oElement)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementSetFocus : параметр не является объектом"), 0)
  Local $iErrorCode = $oElement.SetFocus()
  If $iErrorCode Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementSetFocus : ошибка выполнения метода (0x" & Hex($iErrorCode) & ")"), 0)
  Return 1
EndFunc ; _UIA_ElementSetFocus

; ============================================================================================
; Имя функции : _UIA_ElementTextSetValue
; Описание    : Устанавливает значение (текст) в текстовый элемент
; Синтаксис   : _UIA_ElementTextSetValue($oElement, $sValue)
; Параметры   : $oElement - элемент (объект)
;             : $sValue   - новое значение (текст)
; Возвращает  : Успех   - 1
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - ошибка создания объекта на основе шаблона LegacyIAccessible
;             :         @error = 3 - ошибка выполнения метода
; Автор       : InnI
; Примечание  : Только для текстовых элементов, имеющих шаблон ValuePattern
; ============================================================================================
Func _UIA_ElementTextSetValue($oElement, $sValue)
  If Not IsObj($oElement) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ElementTextSetValue : первый параметр не является объектом"), 0)
  Local $pIAccess, $oIAccess
  $oElement.GetCurrentPattern($UIA_LegacyIAccessiblePatternId, $pIAccess)
  $oIAccess = ObjCreateInterface($pIAccess, $sIID_IUIAutomationLegacyIAccessiblePattern, $dtagIUIAutomationLegacyIAccessiblePattern)
  If Not IsObj($oIAccess) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_ElementTextSetValue : ошибка создания объекта на основе шаблона LegacyIAccessible"), 0)
  Local $iErrorCode = $oIAccess.SetValue($sValue)
  If $iErrorCode Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_ElementTextSetValue : ошибка выполнения метода (0x" & Hex($iErrorCode) & ")"), 0)
  Return 1
EndFunc ; _UIA_ElementTextSetValue

; ============================================================================================
; Имя функции : _UIA_FindAllElements
; Описание    : Находит все элементы, соответствующие заданному свойству и его значению
; Синтаксис   : _UIA_FindAllElements($oElementFrom[, $vProperty = 0[, $vPropertyValue = ""]])
; Параметры   : $oElementFrom   - элемент (объект), от которого начинается поиск
;             : $vProperty      - свойство искомого элемента (по умолчанию 0 - любое)
;             : $vPropertyValue - значение свойства искомого элемента (по умолчанию пустая строка)
; Возвращает  : Успех   - массив элементов (объектов)
;             :         $aArray[0] - количество найденных элементов (N)
;             :         $aArray[1] - первый найденный элемент (объект)
;             :         $aArray[2] - второй найденный элемент (объект)
;             :         $aArray[N] - N-й найденный элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - ошибка преобразования свойства
;             :         @error = 3 - ошибка создания условия поиска (см. примечание о типизации)
;             :         @error = 4 - ошибка создания массива элементов (объектов)
; Автор       : InnI
; Примечание  : Поиск производится от указанного элемента по его дереву и всем поддеревьям
;             : Сам элемент, от которого производится поиск, в результат не включается
;             : При поиске любых элементов ($vProperty = 0) значение свойства не учитывается
;             : Название свойства можно скопировать из левой части списка утилиты Inspect
;             : Значение свойства можно скопировать из правой части списка утилиты Inspect
;             : Значения свойств типизированы. Например, для свойства "IsEnabled" нужно указывать значение True, а не 1 и не "True"
; ============================================================================================
Func _UIA_FindAllElements($oElementFrom, $vProperty = 0, $vPropertyValue = "")
  If Not IsObj($oElementFrom) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_FindAllElements : первый параметр не является объектом"), 0)
  Local $oCondition
  If Not $vProperty Then
    $oCondition = Default
  Else
    $vProperty = __UIA_GetPropIdFromStr($vProperty, "_UIA_FindAllElements")
    If $vProperty = -1 Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_FindAllElements : ошибка преобразования свойства"), 0)
    $oCondition = _UIA_CreatePropertyCondition($vProperty, $vPropertyValue)
    If Not IsObj($oCondition) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_FindAllElements : ошибка создания условия поиска (см. примечание о типизации)"), 0)
  EndIf
  Local $aElements = _UIA_FindAllElementsEx($oElementFrom, $oCondition)
  If Not IsArray($aElements) Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_FindAllElements : ошибка создания массива элементов (объектов)"), 0)
  Return $aElements
EndFunc ; _UIA_FindAllElements

; ============================================================================================
; Имя функции : _UIA_FindAllElementsEx
; Описание    : Находит все элементы, соответствующие условию поиска
; Синтаксис   : _UIA_FindAllElementsEx($oElementFrom[, $oCondition = Default[, $iTreeScope = Default]])
; Параметры   : $oElementFrom - элемент (объект), от которого начинается поиск
;             : $oCondition   - условие поиска (по умолчанию любое)
;             : $iTreeScope   - область поиска:
;             :               $TreeScope_Element - включает только сам элемент
;             :               $TreeScope_Children - включает только дочерние элементы
;             :               $TreeScope_Descendants - включает всех потомков элемента (по умолчанию)
;             :               $TreeScope_Subtree - включает сам элемент и всех потомков
; Возвращает  : Успех   - массив элементов (объектов)
;             :         $aArray[0] - количество найденных элементов (N)
;             :         $aArray[1] - первый найденный элемент (объект)
;             :         $aArray[2] - второй найденный элемент (объект)
;             :         $aArray[N] - N-й найденный элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - условие поиска не определено
;             :         @error = 3 - ошибка создания объекта массива
;             :         @error = 4 - ошибка создания массива элементов (объектов)
; Автор       : InnI
; Примечание  : Области поиска $TreeScope_Parent и $TreeScope_Ancestors не поддерживаются
; ============================================================================================
Func _UIA_FindAllElementsEx($oElementFrom, $oCondition = Default, $iTreeScope = Default)
  If Not IsObj($oElementFrom) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_FindAllElementsEx : первый параметр не является объектом"), 0)
  If $oCondition = Default Then
    Local $pCondition, $oUIAutomation = _UIA_ObjectCreate()
    $oUIAutomation.CreateTrueCondition($pCondition)
    $oCondition = ObjCreateInterface($pCondition, $sIID_IUIAutomationBoolCondition, $dtagIUIAutomationBoolCondition)
  EndIf
  If Not IsObj($oCondition) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_FindAllElementsEx : условие поиска не определено"), 0)
  If $iTreeScope = Default Then $iTreeScope = $TreeScope_Descendants
  Local $pUIElementArray, $oUIElementArray, $pUIElement, $iElements
  $oElementFrom.FindAll($iTreeScope, $oCondition, $pUIElementArray)
  $oUIElementArray = ObjCreateInterface($pUIElementArray, $sIID_IUIAutomationElementArray, $dtagIUIAutomationElementArray)
  If Not IsObj($oUIElementArray) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_FindAllElementsEx : ошибка создания объекта массива"), 0)
  $oUIElementArray.Length($iElements)
  If Not $iElements Then
    Local $aElements[1] = [0]
    Return $aElements
  EndIf
  Local $aElements[$iElements + 1]
  $aElements[0] = $iElements
  For $i = 1 To $iElements
    $oUIElementArray.GetElement($i - 1, $pUIElement)
    $aElements[$i] = __UIA_CreateElement($pUIElement)
    $pUIElement = 0
  Next
  If Not IsArray($aElements) Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_FindAllElementsEx : ошибка создания массива элементов (объектов)"), 0)
  Return $aElements
EndFunc ; _UIA_FindAllElementsEx

; ============================================================================================
; Имя функции : _UIA_FindElementsInArray
; Описание    : Находит все элементы, соответствующие заданному свойству и его значению
;Синтаксис   : _UIA_FindElementsInArray(Const ByRef $aElements, $vProperty, $vPropertyValue[, $fInStr = False[, $fIndexArray = False]])
; Параметры   : $aElements      - массив элементов (объектов)
;             : $vProperty      - свойство искомого элемента
;             : $vPropertyValue - значение свойства искомого элемента
;             : $fInStr         - полное совпадение значения свойства (по умолчанию) или частичное
;             : $fIndexArray    - элементами массива являются объекты (по умолчанию) или индексы элементов исходного массива
; Возвращает  : Успех   - массив элементов (объектов)
;             :         $aArray[0] - количество найденных элементов (N)
;             :         $aArray[1] - первый найденный элемент (объект)
;             :         $aArray[2] - второй найденный элемент (объект)
;             :         $aArray[N] - N-й найденный элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является массивом
;             :         @error = 2 - пустой массив
;             :         @error = 3 - многомерный массив
;             :         @error = 4 - элемент массива [0] не соответствует количеству остальных элементов
;             :         @error = 5 - массив не содержит элементов
;             :         @error = 6 - элемент массива [индекс] не является объектом
;             :         @error = 7 - ошибка преобразования свойства
; Автор       : InnI
; Примечание  : Элемент массива с нулевым индексом должен содержать количество объектов
;             : Название свойства можно скопировать из левой части списка утилиты Inspect
;             : Значение свойства можно скопировать из правой части списка утилиты Inspect
; ============================================================================================
Func _UIA_FindElementsInArray(Const ByRef $aElements, $vProperty, $vPropertyValue, $fInStr = False, $fIndexArray = False)
  If Not IsArray($aElements) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_FindElementsInArray : первый параметр не является массивом"), 0)
  If Not UBound($aElements) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_FindElementsInArray : пустой массив"), 0)
  If UBound($aElements, 0) > 1 Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_FindElementsInArray : многомерный массив"), 0)
  If $aElements[0] <> UBound($aElements) - 1 Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_FindElementsInArray : элемент массива [0] не соответствует количеству остальных элементов"), 0)
  If Not $aElements[0] Then Return SetError(5, __UIA_ConsoleWriteError("_UIA_FindElementsInArray : массив не содержит элементов"), 0)
  For $i = 1 To $aElements[0]
    If Not IsObj($aElements[$i]) Then Return SetError(6, __UIA_ConsoleWriteError("_UIA_FindElementsInArray : элемент массива [" & $i & "] не является объектом"), 0)
  Next
  $vProperty = __UIA_GetPropIdFromStr($vProperty, "_UIA_FindElementsInArray")
  If $vProperty = -1 Then Return SetError(7, __UIA_ConsoleWriteError("_UIA_FindElementsInArray : ошибка преобразования свойства"), 0)
  Local $vValue, $aArray[$aElements[0] + 1], $j = 1
  For $i = 1 To $aElements[0]
    $aElements[$i].GetCurrentPropertyValue($vProperty, $vValue)
    If $fInStr Then
      If StringInStr($vValue, $vPropertyValue) Then
        If $fIndexArray Then
          $aArray[$j] = $i
        Else
          $aArray[$j] = $aElements[$i]
        EndIf
        $j += 1
      EndIf
    Else
      If $vPropertyValue = $vValue Then
        If $fIndexArray Then
          $aArray[$j] = $i
        Else
          $aArray[$j] = $aElements[$i]
        EndIf
        $j += 1
      EndIf
    EndIf
    $vValue = 0
  Next
  ReDim $aArray[$j]
  $aArray[0] = $j - 1
  Return $aArray
EndFunc ; _UIA_FindElementsInArray

; ============================================================================================
; Имя функции : _UIA_GetControlTypeElement
; Описание    : Находит элемент (объект) указанного типа с заданным свойством и значением
; Синтаксис   : _UIA_GetControlTypeElement($oElementFrom, $vControlType, $vPropertyValue[, $vProperty = Default[, $fInStr = False]])
; Параметры   : $oElementFrom   - элемент (объект), от которого начинается поиск
;             : $vControlType   - идентификатор типа искомого элемента
;             : $vPropertyValue - значение свойства искомого элемента
;             : $vProperty      - свойство искомого элемента (по умолчанию "Name" - $UIA_NamePropertyId)
;             : $fInStr         - полное совпадение значения свойства (по умолчанию) или частичное
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - ошибка преобразования типа
;             :         @error = 3 - ошибка преобразования свойства
;             :         @error = 4 - ошибка создания массива элементов (объектов)
;             :         @error = 5 - элементы указанного типа не найдены
;             :         @error = 6 - значение указанного свойства найденных элементов не соответствует заданному
; Автор       : InnI
; Примечание  : Поиск производится от указанного элемента по его дереву и всем поддеревьям
;             : Идентификатор типа можно скопировать из значения свойства "ControlType" утилиты Inspect
;             : Название свойства можно скопировать из левой части списка утилиты Inspect
;             : Значение свойства можно скопировать из правой части списка утилиты Inspect
; ============================================================================================
Func _UIA_GetControlTypeElement($oElementFrom, $vControlType, $vPropertyValue, $vProperty = Default, $fInStr = False)
  If Not IsObj($oElementFrom) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_GetControlTypeElement : первый параметр не является объектом"), 0)
  $vControlType = __UIA_GetTypeIdFromStr($vControlType, "_UIA_GetControlTypeElement")
  If $vControlType = -1 Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_GetControlTypeElement : ошибка преобразования типа"), 0)
  If $vProperty = Default Then
    $vProperty = $UIA_NamePropertyId
  Else
    $vProperty = __UIA_GetPropIdFromStr($vProperty, "_UIA_GetControlTypeElement")
    If $vProperty = -1 Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_GetControlTypeElement : ошибка преобразования свойства"), 0)
  EndIf
  Local $aElements = _UIA_FindAllElements($oElementFrom, $UIA_ControlTypePropertyId, $vControlType)
  If Not IsArray($aElements) Then Return SetError(4, __UIA_ConsoleWriteError("_UIA_GetControlTypeElement : ошибка создания массива элементов (объектов)"), 0)
  If Not $aElements[0] Then Return SetError(5, __UIA_ConsoleWriteError("_UIA_GetControlTypeElement : элементы указанного типа не найдены"), 0)
  Local $vValue
  For $i = 1 To $aElements[0]
    $aElements[$i].GetCurrentPropertyValue($vProperty, $vValue)
    If $fInStr Then
      If StringInStr($vValue, $vPropertyValue) Then ExitLoop
    Else
      If $vPropertyValue = $vValue Then ExitLoop
    EndIf
    $vValue = 0
  Next
  If $i = $aElements[0] + 1 Then Return SetError(6, __UIA_ConsoleWriteError("_UIA_GetControlTypeElement : значение указанного свойства найденных элементов не соответствует заданному"), 0)
  Return $aElements[$i]
EndFunc ; _UIA_GetControlTypeElement

; ============================================================================================
; Имя функции : _UIA_GetElementFromCondition
; Описание    : Находит элемент (объект) на основе заданного условия
; Синтаксис   : _UIA_GetElementFromCondition($oElementFrom, $oCondition[, $iTreeScope = Default])
; Параметры   : $oElementFrom - элемент (объект), от которого начинается поиск
;             : $oCondition   - условие поиска
;             : $iTreeScope   - область поиска:
;             :               $TreeScope_Element - включает только сам элемент
;             :               $TreeScope_Children - включает только дочерние элементы
;             :               $TreeScope_Descendants - включает всех потомков элемента (по умолчанию)
;             :               $TreeScope_Subtree - включает сам элемент и всех потомков
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - условие поиска не определено
;             :         @error = 3 - ошибка выполнения метода
; Автор       : InnI
; Примечание  : Если элемент не найден, то функция вернёт НЕ объект
;             : Области поиска $TreeScope_Parent и $TreeScope_Ancestors не поддерживаются
; ============================================================================================
Func _UIA_GetElementFromCondition($oElementFrom, $oCondition, $iTreeScope = Default)
  If Not IsObj($oElementFrom) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_GetElementFromCondition : первый параметр не является объектом"), 0)
  If Not IsObj($oCondition) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_GetElementFromCondition : условие поиска не определено"), 0)
  If $iTreeScope = Default Then $iTreeScope = $TreeScope_Descendants
  Local $pUIElement, $iErrorCode = $oElementFrom.FindFirst($iTreeScope, $oCondition, $pUIElement)
  If $iErrorCode Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_GetElementFromCondition : ошибка выполнения метода (0x" & Hex($iErrorCode) & ")"), 0)
  Return __UIA_CreateElement($pUIElement)
EndFunc ; _UIA_GetElementFromCondition

; ============================================================================================
; Имя функции : _UIA_GetElementFromFocus
; Описание    : Создаёт элемент (объект) на основе фокуса ввода
; Синтаксис   : _UIA_GetElementFromFocus()
; Параметры   :
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - ошибка создания объекта UIAutomation
;             :         @error = 2 - ошибка создания элемента (объекта)
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func _UIA_GetElementFromFocus()
  Local $pElement, $oElement, $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_GetElementFromFocus : ошибка создания объекта UIAutomation"), 0)
  $oUIAutomation.GetFocusedElement($pElement)
  $oElement = __UIA_CreateElement($pElement)
  $pElement = 0
  If Not IsObj($oElement) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_GetElementFromFocus : ошибка создания элемента (объекта)"), 0)
  Return $oElement
EndFunc ; _UIA_GetElementFromFocus

; ============================================================================================
; Имя функции : _UIA_GetElementFromHandle
; Описание    : Создаёт элемент (объект) на основе дескриптора
; Синтаксис   : _UIA_GetElementFromHandle($hHandle)
; Параметры   : $hHandle - дескриптор окна или контрола
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - параметр не является дескриптором
;             :         @error = 2 - ошибка создания объекта UIAutomation
;             :         @error = 3 - ошибка создания элемента (объекта)
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func _UIA_GetElementFromHandle($hHandle)
  If Not IsHWnd($hHandle) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_GetElementFromHandle : параметр не является дескриптором"), 0)
  Local $pElement, $oElement, $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_GetElementFromHandle : ошибка создания объекта UIAutomation"), 0)
  $oUIAutomation.ElementFromHandle($hHandle, $pElement)
  $oElement = __UIA_CreateElement($pElement)
  $pElement = 0
  If Not IsObj($oElement) Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_GetElementFromHandle : ошибка создания элемента (объекта)"), 0)
  Return $oElement
EndFunc ; _UIA_GetElementFromHandle

; ============================================================================================
; Имя функции : _UIA_GetElementFromPoint
; Описание    : Создаёт элемент (объект) на основе экранных координат
; Синтаксис   : _UIA_GetElementFromPoint($iX = Default, $iY = Default)
; Параметры   : $iX - X координата экрана (по умолчанию - курсора мыши)
;             : $iY - Y координата экрана (по умолчанию - курсора мыши)
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - ошибка создания объекта UIAutomation
;             :         @error = 2 - ошибка создания элемента (объекта)
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func _UIA_GetElementFromPoint($iX = Default, $iY = Default)
  Local $pElement, $oElement, $tPoint = DllStructCreate("long X;long Y"), $oUIAutomation = _UIA_ObjectCreate()
  If @error Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_GetElementFromPoint : ошибка создания объекта UIAutomation"), 0)
  Local $iMode = Opt("MouseCoordMode", 1)
  $tPoint.X = ($iX = Default) ? MouseGetPos(0) : $iX
  $tPoint.Y = ($iY = Default) ? MouseGetPos(1) : $iY
  Opt("MouseCoordMode", $iMode)
  $oUIAutomation.ElementFromPoint($tPoint, $pElement)
  $oElement = __UIA_CreateElement($pElement)
  $pElement = 0
  If Not IsObj($oElement) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_GetElementFromPoint : ошибка создания элемента (объекта)"), 0)
  Return $oElement
EndFunc ; _UIA_GetElementFromPoint

; ============================================================================================
; Имя функции : _UIA_ObjectCreate
; Описание    : Создаёт объект UIAutomation
; Синтаксис   : _UIA_ObjectCreate()
; Параметры   :
; Возвращает  : Успех   - объект UIAutomation
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - ошибка создания объекта UIAutomation
;             :         @error = 2 - неизвестная версия элемента
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func _UIA_ObjectCreate()
  Local $oUIAutomation
  Switch $UIA_ElementVersion
    Case 0
      For $i = 4 To 2 Step -1
        $oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation8, Eval("sIID_IUIAutomation" & $i), Eval("dtagIUIAutomation" & $i))
        If IsObj($oUIAutomation) Then Return $oUIAutomation
      Next
      ContinueCase
    Case 1
      $oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation, $sIID_IUIAutomation, $dtagIUIAutomation)
    Case 2
      $oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation8, $sIID_IUIAutomation2, $dtagIUIAutomation2)
    Case 3 To 5
      $oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation8, $sIID_IUIAutomation3, $dtagIUIAutomation3)
    Case 6 To 7
      $oUIAutomation = ObjCreateInterface($sCLSID_CUIAutomation8, $sIID_IUIAutomation4, $dtagIUIAutomation4)
    Case Else
      Return SetError(2, __UIA_ConsoleWriteError("_UIA_ObjectCreate : неизвестная версия элемента (" & $UIA_ElementVersion & ")"), 0)
  EndSwitch
  If Not IsObj($oUIAutomation) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_ObjectCreate : ошибка создания объекта UIAutomation"), 0)
  Return $oUIAutomation
EndFunc ; _UIA_ObjectCreate

; ============================================================================================
; Имя функции : _UIA_WaitControlTypeElement
; Описание    : Ожидает элемент (объект) указанного типа с заданным свойством и значением
; Синтаксис   : _UIA_WaitControlTypeElement($oElementFrom, $vControlType, $vPropertyValue[, $vProperty = Default[, $fInStr = False[, $iWaitTime = Default]]])
; Параметры   : $oElementFrom   - элемент (объект), от которого начинается поиск
;             : $vControlType   - идентификатор типа ожидаемого элемента
;             : $vPropertyValue - значение свойства ожидаемого элемента
;             : $vProperty      - свойство ожидаемого элемента (по умолчанию "Name" - $UIA_NamePropertyId)
;             : $fInStr         - полное совпадение значения свойства (по умолчанию) или частичное
;             : $iWaitTime      - время ожидания в секундах (по умолчанию $UIA_DefaultWaitTime, 0 - бесконечно)
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - ошибка преобразования типа
;             :         @error = 3 - ошибка преобразования свойства
;             :         @error = 4 - превышено время ожидания
; Автор       : InnI
; Примечание  : Поиск производится от указанного элемента по его дереву и всем поддеревьям
;             : Идентификатор типа можно скопировать из значения свойства "ControlType" утилиты Inspect
;             : Название свойства можно скопировать из левой части списка утилиты Inspect
;             : Значение свойства можно скопировать из правой части списка утилиты Inspect
; ============================================================================================
Func _UIA_WaitControlTypeElement($oElementFrom, $vControlType, $vPropertyValue, $vProperty = Default, $fInStr = False, $iWaitTime = Default)
  If Not IsObj($oElementFrom) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_WaitControlTypeElement : первый параметр не является объектом"), 0)
  $vControlType = __UIA_GetTypeIdFromStr($vControlType, "_UIA_WaitControlTypeElement")
  If $vControlType = -1 Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_WaitControlTypeElement : ошибка преобразования типа"), 0)
  If $vProperty = Default Then
    $vProperty = $UIA_NamePropertyId
  Else
    $vProperty = __UIA_GetPropIdFromStr($vProperty, "_UIA_WaitControlTypeElement")
    If $vProperty = -1 Then Return SetError(3, __UIA_ConsoleWriteError("_UIA_WaitControlTypeElement : ошибка преобразования свойства"), 0)
  EndIf
  If $iWaitTime = Default Then $iWaitTime = $UIA_DefaultWaitTime
  Local $oElement, $iOption = $UIA_ConsoleWriteError, $iTimer = TimerInit()
  $UIA_ConsoleWriteError = 0
  Do
    $oElement = _UIA_GetControlTypeElement($oElementFrom, $vControlType, $vPropertyValue, $vProperty, $fInStr)
    If IsObj($oElement) Then
      $UIA_ConsoleWriteError = $iOption
      Return $oElement
    EndIf
    If $iWaitTime > 0 And TimerDiff($iTimer) > $iWaitTime * 1000 Then
      $UIA_ConsoleWriteError = $iOption
      Return SetError(4, __UIA_ConsoleWriteError("_UIA_WaitControlTypeElement : превышено время ожидания"), 0)
    EndIf
    Sleep(100)
  Until 0
EndFunc ; _UIA_WaitControlTypeElement

; ============================================================================================
; Имя функции : _UIA_WaitElementFromCondition
; Описание    : Ожидает элемент (объект) на основе заданного условия
; Синтаксис   : _UIA_WaitElementFromCondition($oElementFrom, $oCondition[, $iTreeScope = Default[, $iWaitTime = Default]])
; Параметры   : $oElementFrom - элемент (объект), от которого начинается поиск
;             : $oCondition   - условие поиска
;             : $iTreeScope   - область поиска:
;             :               $TreeScope_Element - включает только сам элемент
;             :               $TreeScope_Children - включает только дочерние элементы
;             :               $TreeScope_Descendants - включает всех потомков элемента (по умолчанию)
;             :               $TreeScope_Subtree - включает сам элемент и всех потомков
;             : $iWaitTime    - время ожидания в секундах (по умолчанию $UIA_DefaultWaitTime, 0 - бесконечно)
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0 и устанавливает @error
;             :         @error = 1 - первый параметр не является объектом
;             :         @error = 2 - условие поиска не определено
;             :         @error = 3 - превышено время ожидания
; Автор       : InnI
; Примечание  : Области поиска $TreeScope_Parent и $TreeScope_Ancestors не поддерживаются
; ============================================================================================
Func _UIA_WaitElementFromCondition($oElementFrom, $oCondition, $iTreeScope = Default, $iWaitTime = Default)
  If Not IsObj($oElementFrom) Then Return SetError(1, __UIA_ConsoleWriteError("_UIA_WaitElementFromCondition : первый параметр не является объектом"), 0)
  If Not IsObj($oCondition) Then Return SetError(2, __UIA_ConsoleWriteError("_UIA_WaitElementFromCondition : условие поиска не определено"), 0)
  If $iTreeScope = Default Then $iTreeScope = $TreeScope_Descendants
  If $iWaitTime = Default Then $iWaitTime = $UIA_DefaultWaitTime
  Local $oElement, $iOption = $UIA_ConsoleWriteError, $iTimer = TimerInit()
  $UIA_ConsoleWriteError = 0
  Do
    $oElement = _UIA_GetElementFromCondition($oElementFrom, $oCondition, $iTreeScope)
    If IsObj($oElement) Then
      $UIA_ConsoleWriteError = $iOption
      Return $oElement
    EndIf
    If $iWaitTime > 0 And TimerDiff($iTimer) > $iWaitTime * 1000 Then
      $UIA_ConsoleWriteError = $iOption
      Return SetError(3, __UIA_ConsoleWriteError("_UIA_WaitElementFromCondition : превышено время ожидания"), 0)
    EndIf
    Sleep(100)
  Until 0
EndFunc ; _UIA_WaitElementFromCondition

; ============================================================================================
; Для внутреннего использования
; ============================================================================================
; Имя функции : __UIA_ConsoleWriteError
; Описание    : Выводит описания ошибок в консоль
; Синтаксис   : __UIA_ConsoleWriteError($sString)
; Параметры   : $sString - строка с описанием ошибки
; Возвращает  : Ничего
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func __UIA_ConsoleWriteError($sString)
  If $UIA_ConsoleWriteError Then ConsoleWrite("!> " & $sString & @CRLF)
EndFunc ; __UIA_ConsoleWriteError

; ============================================================================================
; Имя функции : __UIA_CreateElement
; Описание    : Создаёт элемент (объект)
; Синтаксис   : __UIA_CreateElement($pElement)
; Параметры   : $pElement - указатель на элемент
; Возвращает  : Успех   - элемент (объект)
;             : Неудача - 0
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func __UIA_CreateElement($pElement)
  If Not $pElement Then Return 0
  Local $oElement, $Ver = ($UIA_ElementVersion = 1) ? "" : $UIA_ElementVersion
  If $UIA_ElementVersion Then
    Return ObjCreateInterface($pElement, Eval("sIID_IUIAutomationElement" & $Ver), Eval("dtagIUIAutomationElement" & $Ver))
  Else
    For $i = 7 To 2 Step -1
      $oElement = ObjCreateInterface($pElement, Eval("sIID_IUIAutomationElement" & $i), Eval("dtagIUIAutomationElement" & $i))
      If IsObj($oElement) Then Return $oElement
    Next
    Return ObjCreateInterface($pElement, $sIID_IUIAutomationElement, $dtagIUIAutomationElement)
  EndIf
EndFunc ; __UIA_CreateElement

; ============================================================================================
; Имя функции : __UIA_GetPropIdFromStr
; Описание    : Преобразует отображаемое в утилите Inspect свойство в его числовой идентификатор
; Синтаксис   : __UIA_GetPropIdFromStr($sString[, $sFuncName = ""])
; Параметры   : $sString   - строка, отображаемая в левой части списка утилиты Inspect
;             : $sFuncName - имя вызывающей функции
; Возвращает  : Успех   - числовой идентификатор свойства
;             : Неудача - -1 и устанавливает @error
;             :         @error = 1 - ошибка преобразования строки в идентификатор свойства
;             :         @error = 2 - неизвестный идентификатор свойства
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func __UIA_GetPropIdFromStr($sString, $sFuncName = "")
  Local $iPropertyID, $sStr = StringReplace(StringRegExpReplace($sString, "[\.:\h]", ""), "property", "")
  If Int($sStr) Then
    $iPropertyID = Int($sStr)
  Else
    $iPropertyID = Eval("UIA_" & $sStr & "PropertyID")
    If @error Then Return SetError(1, __UIA_ConsoleWriteError($sFuncName & ' : ошибка преобразования строки "' & $sString & '" в идентификатор свойства'), -1)
  EndIf
  If $iPropertyID < 30000 Or $iPropertyID > 30167 Then
    Return SetError(2, __UIA_ConsoleWriteError($sFuncName & " : неизвестный идентификатор свойства (" & $iPropertyID & ")"), -1)
  Else
    Return $iPropertyID
  EndIf
EndFunc ; __UIA_GetPropIdFromStr

; ============================================================================================
; Имя функции : __UIA_GetTypeIdFromStr
; Описание    : Преобразует отображаемое в утилите Inspect значение свойства ControlType в числовой идентификатор
; Синтаксис   : __UIA_GetTypeIdFromStr($sString[, $sFuncName = ""])
; Параметры   : $sString - строка, отображаемая в значении свойства ControlType утилиты Inspect
;             : $sFuncName - имя вызывающей функции
; Возвращает  : Успех   - числовой идентификатор типа
;             : Неудача - -1 и устанавливает @error
;             :         @error = 1 - ошибка преобразования строки в идентификатор типа
;             :         @error = 2 - неизвестный идентификатор типа
; Автор       : InnI
; Примечание  :
; ============================================================================================
Func __UIA_GetTypeIdFromStr($sString, $sFuncName = "")
  Local $iControlTypeID, $sStr = StringRegExpReplace($sString, "[\)\(\h]", "")
  If Int($sStr) Then
    $iControlTypeID = Int($sStr)
  Else
    $sStr = StringRegExp($sStr, "(?i)uia_.+typeid", 1)
    If IsArray($sStr) And IsDeclared($sStr[0]) Then
      $iControlTypeID = Eval($sStr[0])
    Else
      Return SetError(1, __UIA_ConsoleWriteError($sFuncName & ' : ошибка преобразования строки "' & $sString & '" в идентификатор типа'), -1)
    EndIf
  EndIf
  If $iControlTypeID < 50000 Or $iControlTypeID > 50040 Then
    Return SetError(2, __UIA_ConsoleWriteError($sFuncName & " : неизвестный идентификатор типа (" & $iControlTypeID & ")"), -1)
  Else
    Return $iControlTypeID
  EndIf
EndFunc ; __UIA_GetTypeIdFromStr

; #ДАННЫЕ_ДЛЯ_SCITE# =========================================================================
; Всплывающий список функций (файл au3.user.calltips.api)
#cs
_UIA_CreateLogicalCondition($oCondition1[, $sOperator = "NOT"[, $oCondition2 = 0]]) Создаёт логическое условие на основе заданных условий (Требуется: #include <UIAutomation.au3>)
_UIA_CreatePropertyCondition($vProperty, $vPropertyValue) Создаёт условие на основе свойства и его значения (Требуется: #include <UIAutomation.au3>)
_UIA_ElementDoDefaultAction($oElement) Выполнение элементом действия по умолчанию (Требуется: #include <UIAutomation.au3>)
_UIA_ElementFindInArray(Const ByRef $aElements, $vProperty, $vPropertyValue[, $fInStr = False[, $iStartIndex = 1[, $fToEnd = True]]]) Находит элемент, соответствующий заданному свойству и его значению (Требуется: #include <UIAutomation.au3>)
_UIA_ElementGetBoundingRectangle($oElement) Определяет прямоугольную область, ограничивающую элемент (Требуется: #include <UIAutomation.au3>)
_UIA_ElementGetFirstLastChild($oElement) Находит первый и последний дочерние элементы (объекты) указанного элемента (Требуется: #include <UIAutomation.au3>)
_UIA_ElementGetParent($oElement) Определяет родительский элемент (объект) указанного элемента (Требуется: #include <UIAutomation.au3>)
_UIA_ElementGetPreviousNext($oElement) Находит предыдущий и следующий элементы (объекты) того же уровня (Требуется: #include <UIAutomation.au3>)
_UIA_ElementGetPropertyValue($oElement, $vProperty) Определяет значение заданного свойства элемента (Требуется: #include <UIAutomation.au3>)
_UIA_ElementMouseClick($oElement[, $sButton = ""[, $iX = Default[, $iY = Default[, $iClicks = 1[, $fSetFocus = True]]]]]) Выполняет клик мыши по элементу (Требуется: #include <UIAutomation.au3>)
_UIA_ElementScrollIntoView($oElement) Прокручивает элемент в область видимости (Требуется: #include <UIAutomation.au3>)
_UIA_ElementSetFocus($oElement) Устанавливает элементу фокус ввода (Требуется: #include <UIAutomation.au3>)
_UIA_ElementTextSetValue($oElement, $sValue) Устанавливает значение (текст) в текстовый элемент (Требуется: #include <UIAutomation.au3>)
_UIA_FindAllElements($oElementFrom[, $vProperty = 0[, $vPropertyValue = ""]]) Находит все элементы, соответствующие заданному свойству и его значению (Требуется: #include <UIAutomation.au3>)
_UIA_FindAllElementsEx($oElementFrom[, $oCondition = Default[, $iTreeScope = Default]]) Находит все элементы, соответствующие условию поиска (Требуется: #include <UIAutomation.au3>)
_UIA_FindElementsInArray(Const ByRef $aElements, $vProperty, $vPropertyValue[, $fInStr = False[, $fIndexArray = False]]) Находит все элементы, соответствующие заданному свойству и его значению (Требуется: #include <UIAutomation.au3>)
_UIA_GetControlTypeElement($oElementFrom, $vControlType, $vPropertyValue[, $vProperty = Default[, $fInStr = False]]) Находит элемент (объект) указанного типа с заданным свойством и значением (Требуется: #include <UIAutomation.au3>)
_UIA_GetElementFromCondition($oElementFrom, $oCondition[, $iTreeScope = Default]) Находит элемент (объект) на основе заданного условия (Требуется: #include <UIAutomation.au3>)
_UIA_GetElementFromFocus() Создаёт элемент (объект) на основе фокуса ввода (Требуется: #include <UIAutomation.au3>)
_UIA_GetElementFromHandle($hHandle) Создаёт элемент (объект) на основе дескриптора (Требуется: #include <UIAutomation.au3>)
_UIA_GetElementFromPoint($iX = Default, $iY = Default) Создаёт элемент (объект) на основе экранных координат (Требуется: #include <UIAutomation.au3>)
_UIA_ObjectCreate() Создаёт объект UIAutomation (Требуется: #include <UIAutomation.au3>)
_UIA_WaitControlTypeElement($oElementFrom, $vControlType, $vPropertyValue[, $vProperty = Default[, $fInStr = False[, $iWaitTime = Default]]]) Ожидает элемент (объект) указанного типа с заданным свойством и значением (Требуется: #include <UIAutomation.au3>)
_UIA_WaitElementFromCondition($oElementFrom, $oCondition[, $iTreeScope = Default[, $iWaitTime = Default]]) Ожидает элемент (объект) на основе заданного условия (Требуется: #include <UIAutomation.au3>)
#ce
; Подсветка функций (файл au3.UserUdfs.properties)
#cs
au3.keywords.user.udfs=_uia_createlogicalcondition _uia_createpropertycondition _uia_elementdodefaultaction \
	_uia_elementfindinarray _uia_elementgetboundingrectangle _uia_elementgetfirstlastchild _uia_elementgetparent \
	_uia_elementgetpreviousnext _uia_elementgetpropertyvalue _uia_elementmouseclick _uia_elementscrollintoview \
	_uia_elementsetfocus _uia_elementtextsetvalue _uia_findallelements _uia_findallelementsex _uia_findelementsinarray \
	_uia_getcontroltypeelement _uia_getelementfromcondition _uia_getelementfromfocus _uia_getelementfromhandle \
	_uia_getelementfrompoint _uia_objectcreate _uia_waitcontroltypeelement _uia_waitelementfromcondition
#ce
; ============================================================================================