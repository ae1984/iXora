/* padc.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/*
    14.01.2000
    padc.p
    Выравнивание строки cLine символом cSmb на длину nLen в центр...
    Пропер С.В.
*/

FUNCTION padc RETURNs char ( 
    INPUT cLine AS CHAR, 
    INPUT nLen  AS INTEGER, 
    INPUT cSmb  AS CHAR ).

DEF VAR iLen AS INTEGER.
DEF VAR cSib AS CHAR FORMAT 'x'.
     
    cLine = IF cLine = ? THEN '' ELSE TRIM( cLine ).
    cSmb  = IF cSmb  = ? THEN ' ' ELSE cSmb.
    iLen  = LENGTH( cLine ).
    IF iLen > nLen THEN cLine = SUBSTRING( cLine, 1, nLen ).
    IF iLen < nLen THEN cLine = 
    FILL( cSmb, INT(( nLen - iLen ) / 2 )) + cLine + 
    FILL( cSmb, INT(( nLen - iLen ) / 2 )).
    cLine = SUBSTRING( cLine, 1, nLen ).
    RETURN cLine.
    
END FUNCTION.
/***/
