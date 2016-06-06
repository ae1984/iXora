/* goto2l.p
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

{global.i}
{lgps.i }
def shared var s-remtrz like remtrz.remtrz .
def var yn as log initial false format "Да/Нет".
def var ok as log format "Да/Нет".
def var ourbank as cha . 
def var sender like ptyp.sender .
def var receiver like ptyp.receiver .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 display "Отсутствует запись OURBANK в таблице SYSC!".
  pause .
   undo .
    return .
    end.
    ourbank = sysc.chval.


{ps-prmt.i}

Message "Вы уверены?" update yn .
do  transaction:

find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

find jh where jh.jh = remtrz.jh2 no-error.
if available jh then do:
  Message "2 проводка уже существует!" . pause.
  return.
end.


find jh where jh.jh = remtrz.jh1 no-lock no-error.
if not avail jh and remtrz.source ne "SW" then do:
  Message "Отсутствует первая проводка, отсылка невозможна!" . pause.
  return.
end.

find que of remtrz NO-LOCK no-error.
if not ( que.pid eq 'G' or que.pid eq '3g' or que.pid = '3' or 
 que.pid = "VK" ) then do:
  Message "Код не равен G или 3g или 3 или VK !!! " . pause.
      return.
   end.


if yn then do  :
find first que where que.remtrz = s-remtrz exclusive-lock no-error .
find  first  remtrz  where remtrz.remtrz = s-remtrz exclusive-lock no-error.

if avail que then do :

  remtrz.rbank = ourbank. 
  remtrz.rcbank = ourbank. 
  if remtrz.source = "SW" then
  remtrz.rsub = "swift".
  else
  remtrz.rsub = "brnch". 
  remtrz.cracc = "". 
  remtrz.crgl = 0. 
/*  remtrz.ba = ''. */
  find first bankl where bankl.bank = remtrz.rbank no-lock no-error .
        if avail bankl  then do:
          remtrz.bb[1] = bankl.name.
          remtrz.bb[2] = bankl.addr[1].
          remtrz.bb[3] = bankl.addr[2] + " " + bankl.addr[3].
        end.                          


  find first aaa where aaa.aaa = 
      substr(remtrz.racc,2,10) no-lock no-error . 
        if avail aaa and ( aaa.sta ne "C" ) then do:
           find cif of aaa no-lock no-error . 
           if avail cif and  
            index(remtrz.bn[1] + remtrz.bn[2] + 
             remtrz.bn[3],trim(cif.jss)) > 0  
            then do:  
             remtrz.cracc = substr(remtrz.racc,2,10).
             remtrz.crgl = aaa.gl  .
             remtrz.rsub = "cif" . 
             remtrz.valdt2 = remtrz.valdt1 . 
            end .    
        end . 

 find first bankl where bankl.bank = remtrz.scbank  no-lock no-error .
 if avail bankl then
  if bankl.nu = "u" then sender  = "u". else sender  = "n" .
   find first bankl where bankl.bank = remtrz.rcbank no-lock no-error .
   if avail bankl then
    if bankl.nu = "u" then receiver  = "u". else receiver  = "n" .

    if remtrz.scbank = ourbank then sender = "o" .
    if remtrz.rcbank = ourbank then receiver  = "o" .

    if remtrz.ptype ne "H" and remtrz.ptype ne "M"  then do :
        find first ptyp where ptyp.sender = sender and
        ptyp.receiver = receiver no-lock no-error .
          if avail ptyp then
            remtrz.ptype = ptyp.ptype.
            else remtrz.ptype = "N".
          end .
  if sender = "o" and receiver = "o" then remtrz.ptype = "M".
  que.ptype = remtrz.ptype . 
  que.pid = m_pid.
  que.rcod = "10" .
  v-text = " Отсылка ->2l " + remtrz.remtrz + " тип=" + remtrz.ptype +
     " по маршруту , код возврата = " + que.rcod  .
  run lgps.
  que.con = "F".
  que.dp = today.
  que.tp = time.
 release que .
 release remtrz.
end.
end .
 end. /*transaction*/
