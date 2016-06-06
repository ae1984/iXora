/* acng.p
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
   last change = 14.11.2001, sasco : for CIF : find next account number after
   					       last existing
   13.10.03  marinav закомментарила 169 строку
   20/04/06 nataly добавила тип TSF
   08/06/2010 madiyar - g-bankcode не из справочника
*/
def input parameter v-gl like gl.gl.
def input parameter vmenu as logical. /* если true предлагается отредактировать сгенерированный счет,
                                         false генерируется след. счет автоматически */
def output parameter v-acc as char format "x(9)".

def var g-bankcode as char /*initial "190501914"*/.
def var v-c as char.
def var v-ok as log.
def var o-acc as char format "x(9)".
def var accgrlst as char.
def shared var s-lgr like lgr.lgr.
def var s-code151 as char.
def var do-sel as logical initial true.
def var v-acc2 as char.
def var v-new as char.

def var is_first as log init yes.
def var old_aaa like aaa.aaa.

/*
find sysc where sysc.sysc = "clecod" no-lock no-error.
if not available sysc or sysc.chval = "" or length(sysc.chval) <> 9 then do:
   message "МФО отсутствует в sysc.sysc = clecod. Невозможно сгенерировать счет."
            view-as alert-box.
   return.
end.
else g-bankcode = sysc.chval.
*/

g-bankcode = "190501470".


Function WACNT returns char (input v-acc as char, input v-bcode as char).

def var v-i as int.
def var v-nres as int.
def var v-wstr1 as char.
def var v-wstr2 as char.
def var v-s as char.
def var v-c as char.
def var v-err as log.


v-nres  = 0.
v-wstr1 = SUBSTR(v-Bcode,7,3) + SUBSTR(v-Acc,1,9).
v-wstr2 = '713371371371'.

v-err = no.
do v-i = 1 TO 12:
if not (substring(v-wstr1,v-i,1) ge "0" and substring(v-wstr1,v-i,1) le "9")
then v-err = yes.
end.

v-c = "".

if not v-err then do:
do v-i = 1 TO 12:
  IF v-i eq 10 then next.
v-s = string(
integer(substring(v-wstr1,v-i,1)) *
integer(substr(v-wstr2,v-i,1))
).
v-nres = v-nres + integer(substring(v-s,length(v-s),1)).

/*
displ v-nres with frame a down.
down with frame a.
*/


END.
v-s = string(v-nres * 3).
v-c = substring(v-s,length(v-s),1).
end.

return v-c.

end function.




v-acc = "".
/*-------------------------------------------------------------------*/

find gl where gl.gl eq v-gl no-lock no-error.
if not available gl then return.
if gl.subled ne "" and gl.level eq 1 then do:
find nmbr where nmbr.code = gl.code no-lock no-error.
if available nmbr then do:
v-ok = no.
do while not v-ok:

    do transaction:
        find sysc where sysc.sysc = "acclst" no-lock.
        accgrlst = sysc.chval.
        if do-sel then
         do:
          if s-lgr = "151" then
          do:
             run sel("Выберите счет","200|221|340|363|365|425|461|467|700").
             case integer(return-value):
                when 1 then s-code151 = "cif14".
                when 2 then s-code151 = "cif15".
                when 3 then s-code151 = "cif16".
                when 4 then s-code151 = "cif17".
                when 5 then s-code151 = "cif18".
                when 6 then s-code151 = "cif19".
                when 7 then s-code151 = "cif20".
                when 8 then s-code151 = "cif02".
                when 9 then s-code151 = "cif34".
                otherwise return.
             end case.
             find nmbr where nmbr.code = s-code151.
          end.
          else do:
            if lookup(s-lgr,accgrlst) = 0 then
            do:
               find nmbr where nmbr.code = gl.code exclusive-lock .
            end.
            else
              do:
               find sysc where sysc.sysc = "acc" + s-lgr no-lock no-error.
               if not available sysc then do:
                  message "Не заведена переменная accXXX" skip "для данной группы счетов 9,1,1,3" view-as alert-box.
                  return.
               end.
               find nmbr where nmbr.code = entry(2,sysc.chval) no-error.
               if not available nmbr then do:
                  message "Нет записи для данного кода" skip "в структуре ссылочных номеров" skip "9,1,2,3" view-as alert-box.
                  return.
               end.
              end.
           end.
         end.
/*-------------------------------------------------------------------*/
        v-acc = "".
        if nmbr.nmbr gt 99999 then leave.
        v-acc = string(nmbr.nmbr,"99999").
        v-acc = substring(v-acc,1,3) +
        nmbr.prefix + "0" + substring(v-acc,4,2).
        v-c = wacnt(v-acc,g-bankcode).
        if v-c eq "" then do:
            v-acc = "".
            leave.
        end.
        else substring(v-acc,7,1) = v-c.
        find aaa where aaa.aaa eq v-acc no-lock no-error.
        if available aaa then do:
         /*  message "Найден счет " + v-acc + " CIF " view-as alert-box.
           pause.*/
           do-sel = false.
           nmbr.nmbr = nmbr.nmbr + 1.
           next.
        end.
        else do-sel = true.

        if vmenu then
           update v-acc label "Новый счет "
           with frame a overlay side-label row 10
           centered.

        if not v-acc entered then
        nmbr.nmbr = nmbr.nmbr + 1.
        else do:
            if length(v-acc,"CHARACTER") < 9
               then do:
                    message "Длина счета должна быть 9" view-as alert-box.
                    undo,retry.
               end.

v-acc2 = v-acc.
v-new = "".

do while v-new <> "0":
/* -----------------------------------   14.11.2001 by sasco   ---------- */

if gl.subled eq "CIF" then do:

   if v-new = "" then do:
      find last aaa where substring(aaa.aaa,1,6) = substring(v-acc2,1,6)
      no-lock no-error.
      if avail aaa then
      do:
          v-new = string(integer(substring(aaa.aaa,7,3)) + 1).
          if length(v-new) = 4 then v-new = substring(v-new,1,3).
          v-acc = substring(aaa.aaa,1,6) + v-new.
      end.
      else v-acc = substring(v-acc2,1,6) + "001".
  end.
end.

            v-c = wacnt(v-acc,g-bankcode).
            if v-c ne substring(v-acc,7,1) or v-acc eq "" or v-acc eq ?
            then do:
                   /*  if nmbr.prefix ne substring(v-acc,4,3)
                 then
                   do:
                     message "Некорректный префикс" skip "должен быть:" nmbr.prefix view-as alert-box.
                     undo,retry.
                   end. */
              o-acc = "".
              o-acc = substring(v-acc,1,3) +
              substring(v-acc,4,3) + "0" + substring(v-acc,8,2).
              v-c = wacnt(o-acc,g-bankcode).
              if v-c eq ""
                then
                  do:
                    o-acc = "".
     /*               leave.  */
                  end.
                else substring(o-acc,7,1) = v-c.
            end.

if gl.subled = "CIF" then do:

        if is_first = yes then do: old_aaa = o-acc. is_first = no. end.
        else if o-acc = old_aaa then do: message "Не могу сгенерировать счет! Переполнение номеров!"
                                         view-as alert-box. v-acc = "". return. end.

        find aaa where aaa.aaa = o-acc no-lock no-error.
        if not avail aaa then v-new = "0".
        else do:
                 v-acc = string(integer(o-acc) + 1).
                 if length(v-acc) < 9 then
                    v-acc = "0" + v-acc.
                 if length(v-acc) < 9 then
                    v-acc = "0" + v-acc.
                 if length(v-acc) < 9 then
                    v-acc = "0" + v-acc.
                 v-new = "1".
             end.
end.
else v-new = "0".

if o-acc = "" then do: v-acc = string(integer(v-acc) + 1).
                 if length(v-acc) < 9 then
                    v-acc = "0" + v-acc.
                 if length(v-acc) < 9 then
                    v-acc = "0" + v-acc.
                 if length(v-acc) < 9 then
                    v-acc = "0" + v-acc.
                 v-new = "1".
                 end.
end. /* while */
/* ---------------------------------------  14.11.2001, sasco -------------- */


/*              message "Ошибка контрольного разряда" skip "Должен быть:" o-acc view-as alert-box.
  --------------------------------------------------------------------------------*/
              if o-acc = "" then leave.

              def var l-a as log.
              run yn.p ("Новый счет" , o-acc, "согласны?", "", output l-a).
              if l-a then v-acc = o-acc.
                     else undo,retry.

        end.
    end.
    release nmbr.



{acng.i "AST"}
{acng.i "ARP"}
{acng.i "DFB"}
{acng.i "FUN"}
{acng.i "SCU"}
{acng.i "LON"}
{acng.i "OCK"}
{acng.i "EPS"}
{acng.i "TSF"}





if gl.subled eq "CIF" then do transaction :
create aaa.
aaa.aaa = v-acc no-error.
if error-status:error
   then do:
        message "Такой счет уже существует" view-as alert-box.
        undo,leave.
   end.
v-ok = yes.
end.

if gl.subled eq "lon" then do transaction :
create lon.
lon.lon = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "fun" then do transaction :
create fun.
fun.fun = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "scu" then do transaction :
create scu.
scu.scu = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "tsf" then do transaction :
create tsf.
tsf.tsf = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "arp" then do transaction :
create arp.
arp.arp = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "ast" then do transaction :
create ast.
ast.ast = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "ock" then do transaction :
create ock.
ock.ock = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "eps" then do transaction :
create eps.
eps.eps = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.

if gl.subled eq "dfb" then do transaction :
create dfb.
dfb.dfb = v-acc no-error.
if error-status:error then undo,leave.
v-ok = yes.
end.


end. /* do while */
end.
end.


