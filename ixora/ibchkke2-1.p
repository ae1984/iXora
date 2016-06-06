/* ibchkke2-1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Разблокировать
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
        16.01.2005 tsoy
 * CHANGES
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
    def var v-s as char.

define frame usrnamef
             usrtb format '>>>>>9' label    'Регном. Клиента ' skip
             usrkey  format 'x(06)' label   '            Ключ' skip(2)
             cif.name format 'x(40)' label  'Наименование клиента' skip
             usr.login format "x(25)" label '         Входное имя' skip
             usr.cif format "x(6)" label    '   Код клиента (CIF)' skip
             usr.perm[3] label              '          Блокировка' skip
             usr.perm[6] label              '   Закрыт ли договор' skip
with row 3 centered overlay side-labels.

repeat:
    usrtb  = 0.
    usrkey = "".
    displ usrtb  usrkey with frame usrnamef.

    update usrtb  usrkey with frame usrnamef.

    find ib.usr where usr.id = usrtb no-lock no-error.
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

    if usr.authptype <> 'otp' then do:
       display ' Не otp клиент !'
       with frame aa2 centered.
       next.
    end.

    input through value("/pragma/bin9/r_check.pl " + usr.login + " " + usrkey ) no-echo.
    repeat:
      import v-s.
    end.

    if trim(v-s) <> '1' then message "Не верное значение ключа !" view-as alert-box.
    else do:
                                        
            hide frame aa2.

            display 
                usrtb       
                usrkey      
                cif.name    
                usr.login   
                usr.cif     
                usr.perm[3] 
                usr.perm[6] 
            with frame usrnamef.

            /* открытие доступа клиенту */

            if usr.perm[6] <> 0 then
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
            end.
            else
            /* запрос на снятие блокировки */
            if usr.perm[3] <> 0 then
            do:
                 find current usr exclusive-lock.
                 update usr.perm[3] with frame usrnamef.                     
                 find current usr no-lock.
            end.
    end.


end.

hide frame aa.
return.

