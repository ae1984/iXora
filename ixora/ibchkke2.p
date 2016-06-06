/* ibchkke2.p
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
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
	20.03.2006 u00121 - исправлен column-label из-за ошибки в работе shared library (SYSTEM ERROR: Memory violation. (49)), исправлено по рекемендации ProKb (KB-P25563: Error 49 running a 4GL procedure, stack trace shows umLitGetFmtStr)
*/

/*

    30.03.2000
    TableChecKey.p
    Проверка кодового слова клиента ИО...
    Пропер С.В.
*/

{yes-no.i}      

def var usrid  as integer init 0.
def var usrtb  as integer init 0. 
def var usrnum as integer.
def var usrkey as char.
def var autblk as integer.
def var keynum as integer.
def var otknum as integer.
def var usrtxt as char. 
def var usrwrd as char.
def var aToken as char extent 5.
def var usrtb1 as integer.
def var keyindex as integer.

define frame usrnamef
             usrtb format '>>>>>9' label    'Номер таблицы' skip
             usrnum  format '>>>>9' label   '  Номер ключа' skip
             usrkey  format 'x(08)' label   '         Ключ' skip(2)
             cif.name format 'x(40)' label  'Наименование клиента' skip
             usrtb1 format 'zzz9' label     '     Текущая таблица' skip
             keyindex format "zzz9" label   '        Текущий ключ' skip
             usr.id format "zzz9" label     '       Номер клиента' skip
             usr.login format "x(25)" label '         Входное имя' skip
             usr.cif format "x(6)" label    '   Код клиента (CIF)' skip
             usr.perm[3] label              '          Блокировка' skip
             usr.perm[6] label              '   Закрыт ли договор' skip
            with row 3 centered overlay side-labels.

    displ "" @ cif.name 0 @ keyindex 0 @ usrtb1 0 @ usr.id "" @ usr.login "" @ usr.cif
          ? @ usr.perm[3] ? @ usr.perm[6]
          with frame usrnamef.

repeat:

    usrid  = 0.
    usrtb  = 0.
    usrnum = 0.
    usrid  = integer( substring( aToken[1], 1, 5 )) no-error.
    usrtb  = integer( substring( aToken[2], 1, 5 )) no-error.
    usrnum = integer( substring( aToken[3], 1, 4 )) no-error.
    usrkey = aToken[4].

    release cif.

    update usrtb usrnum usrkey with frame usrnamef.

    find first otktd no-lock where otktd.tnum = usrtb and otktd.state > 0
    no-error.
    if not avail otktd then do:
       message ' Нет такой рабочей таблицы...' view-as alert-box.
       next.
    end.

    if usrkey = '' then do:
       message ' Не введен ключ...' view-as alert-box.
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
                  
    if usrtxt = "no" then message "Не верное значение!" view-as alert-box.

    /*
    else do:
    */
            find ib.usr where usr.id = otktd.id_usr no-lock no-error.
            if not avail usr then do:
               display ' Нет такого клиента в Internet Office...'
               with frame aa1 centered.
               next.
            end.
                                    
            find first cif where cif.cif = usr.cif no-lock no-error.
            if not avail cif then do:
               display ' Нет такого клиента в банке...'
               with frame aa2 centered.
               next.
            end.
                                        
            hide frame aa2.

            keyindex = usr.otk_index - 1.

            usrtb1 = usrtb.

            display trim(trim(cif.prefix) + ' ' + trim(cif.name)) @ cif.name otktd.tn @ usrtb usr.id usr.perm[3] usrtb1 usr.cif usr.perm[6]
                    usr.login keyindex with frame usrnamef.

            /* открытие доступа клиенту */
            if usr.perm[6] <> 0 and usrtxt <> "no" then
            do:
                if yes-no ("Внимание!", "Договор по этому клиенту закрыт!~nОткрыть доступ клиенту?")
                then do:
                        find current usr exclusive-lock.
                        assign ib.usr.perm[6] = 0.
                        if usr.perm[3] <> 0
                           then if yes-no ("", "Снять блокировку?")
                                then assign usr.perm[3] = 0.
                        release ib.usr.
                    end.
                 find current usr no-lock.
            end.
            else
            /* запрос на снятие блокировки */
            if usr.perm[3] <> 0 and usrtxt <> "no" then
            do:
                 find current usr exclusive-lock.
                 update usr.perm[3] with frame usrnamef.                     
                 find current usr no-lock.
            end.


end.

hide frame aa.
return.

