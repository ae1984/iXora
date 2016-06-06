/* ibchkke1.p
 * MODULE
    Internet Office
 * DESCRIPTION
    Проверка кодового слова клиента ИО...
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
        31/10/03 sasco проверка кодовой фразы на принадлежность данному CIF
        30/09/04 sasco Если мы в пункте 1-8-3 то клиент не проверяется если usrcif = '?'
	20.03.2006 u00121 - исправлен column-label из-за ошибки в работе shared library (SYSTEM ERROR: Memory violation. (49)), исправлено по рекемендации ProKb (KB-P25563: Error 49 running a 4GL procedure, stack trace shows umLitGetFmtStr)
*/

/*

    30.03.2000

    TableChecKey.p
    Проверка кодового слова клиента ИО...
    Пропер С.В.
*/
      
def input parameter usrwrd as char.      
def input parameter usrcif as char.      

define shared variable g-fname as character.

def var usrid  as integer init 0.
def var usrtb  as integer init 0. 
def var usrnum as integer.
def var usrkey as char.
def var autblk as integer.
def var keynum as integer.
def var otknum as integer.
def var usrtxt as char. 
def var aToken as char extent 5.
repeat:

    update usrwrd with frame aa overlay.
    otknum = 1.
    keynum = 0.
    aToken[5] = usrwrd.
    do while keynum < 4 and otknum >0.
       otknum         = index( aToken[5], '-' ).
       keynum         = keynum + 1.
       aToken[keynum] = substring( aToken[5], 1, otknum - 1 ).    
       aToken[5]      = substring( aToken[5], otknum + 1 ).
    end.

    usrid  = 0.
    usrtb  = 0.
    usrnum = 0.
    usrid  = integer( substring( aToken[1], 1, 5 )) no-error.
    usrtb  = integer( substring( aToken[2], 1, 5 )) no-error.
    usrnum = integer( substring( aToken[3], 1, 4 )) no-error.
    usrkey = aToken[4].

    update 
    usrwrd  format 'x(23)' column-label '!Кодовая!Фраза' when no
    usrid   format '>>>>9' column-label '!Код!Клиента'
    usrtb   format '>>>>9' column-label '!Номер!Таблицы'
    usrnum  format '>>>9'  column-label '!Номер!Ключа'
    usrkey  format 'x(08)' column-label 'Ключ!'
    with centered row 05 frame aa title '[ Проверка кодового слова ]'.
 
    find first ib.usr no-lock where usr.id = usrid
    no-error.
    if not avail usr then do:
       display ' Нет такого клиента в Internet Office...'
       with frame aa1 centered.
       next.
    end.

    if (usrcif <> ib.usr.cif) and (g-fname <> 'CFINT4') then do:
       display 'Кодовая фраза не принадлежит этому клиенту...'
       with frame aacd2 centered.
       next.
    end.
                            
    find first cif no-lock where cif.cif = usr.cif
    no-error.
    if not avail cif then do:
       display ' Нет такого клиента в банке...'
       with frame aa2 centered.
       next.
    end.
                                        
    display trim(trim(cif.prefix) + ' ' + trim(cif.name)) format 'x(23)' column-label 'Наименование!Клиента' 
    with frame aa.
    find first otktd no-lock where otktd.id_usr = usrid 
    no-error.
    if not avail otktd then do:
        display ' Нет такого клиента...' 
        with frame bb centered.
        next.
    end.

    find first otktd no-lock where otktd.id_usr = usrid and otktd.state >0
    no-error.
    if not avail otktd then do:
        display ' Нет действующих таблиц у клиента...' 
        with frame cc centered.
        next.
    end.

    find first otktd no-lock where otktd.id_usr = usrid and otktd.tnum = usrtb
    no-error.
    if not avail otktd then do:
       display ' Нет такой таблицы у клиента...' 
       with frame dd centered.
       next.
    end.

    if usrkey = '' then do:
       display ' Не введен ключ...'
       with frame ff centered.
       next.
    end.
                                 
    find first supp where 
    supp.type = 2 and 
    index( vchar[1], 'AUT_OTK_BLOCK' ) <> 0      
    no-lock no-error.
    
    autblk = if not avail supp then 10 else supp.vint[1].
    usrnum = usrnum + 1.
    keynum = usrnum MODULO ( autblk * 10 ).
    otknum = INTEGER(( usrnum - keynum ) / ( autblk * 10 )) + 1.
    if keynum = 0 then do: 
       keynum = autblk * 10. 
       otknum = otknum - 1. 
    end.

    find otk where otk.id = otktd.id_otk[otknum] no-lock.
    usrtxt = 'no'.
    input through 
    value( '/usr/dlc/install' ) '-c' 
    value( CAPS( usrkey )) 
    value( otk.val[keynum] ) no-echo.
    import usrtxt.
    input close.
                  
    usrtxt = if usrtxt = 'yes' 
    then ' Кодовое слово указано верно!' 
    else ' В кодовом слове ошибка!'.
    display usrtxt format 'x(30)' with frame ee centered no-label.
    usrnum = usrnum - 1.
                
end.

hide frame aa.
return.
/***/

