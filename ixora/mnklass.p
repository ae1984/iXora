/* mnklass.p
 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Классификация кредита на момент мониторинга
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11- Класифик
 * AUTHOR
        16.03.2005 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i }
/*
s-kdcif = 't25566'.
s-nom = 4.
*/
  
def var v-cod as char.
def var v-param as char.
define var v-rat as deci init 0.

if s-kdcif = '' then return.

find kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom and (kdcifhis.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdcifhis then do:
  message skip " Клиент N" s-kdcif "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.
/*
def var hanket as handle.
run mnlib.p persistent set hanket.
pause 0.
*/
define variable s_rowid as rowid.
def var v-title as char init " КЛАССИФИКАЦИЯ ОБЯЗАТЕЛЬСТВ ".
def var v-fl as inte.

find first kdlonklh where kdlonklh.kdcif = s-kdcif 
                     and kdlonklh.nom = s-nom and (kdlonklh.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
if not avail kdlonklh then do:
  if s-ourbank = kdcifhis.bank then do:
    for each kdklass where kdklass.type = 1 use-index kritcod no-lock .
        create kdlonklh.
        assign kdlonklh.bank = s-ourbank
               kdlonklh.kdcif = s-kdcif 
               kdlonklh.nom = s-nom 
               kdlonklh.kod = kdklass.kod 
               kdlonklh.ln = kdklass.ln
               kdlonklh.who = g-ofc 
               kdlonklh.whn = g-today. 
       find current kdlonklh no-lock no-error.
    end.
  end.
  else do:
    message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
    return.
  end.
end.

/*качество обеспечения*/


{jabrw.i 
&start     = " "
&head      = "kdlonklh"
&headkey   = "kod"
&index     = "cifbank"

&formname  = "mnklass"
&framename = "kdklass"
&frameparm = " "
&where     = " kdlonklh.kdcif = s-kdcif and kdlonklh.nom = s-nom and (kdlonklh.bank = s-ourbank or s-ourbank = 'TXB00') "
&predisplay = " find first kdklass where kdklass.kod = kdlonklh.kod no-lock no-error. "
&addcon    = "false"
&deletecon = "false"
&postcreate = " "

&postupdate   = " find first kdklass where kdklass.kod = kdlonklh.kod no-lock no-error.
                  run value(kdklass.proc) (kdklass.kod).
                  if avail kdklass then disp kdklass.name kdlonklh.val1 kdlonklh.valdesc kdlonklh.rating with frame kdklass. "

&prechoose = " hide message. message 'F4 - выход, P - печать'."

&postdisplay = " "

&display   = " kdklass.name kdlonklh.val1 kdlonklh.valdesc kdlonklh.rating "
&update    = " kdlonklh.val1 "
&highlight = " kdlonklh.val1 "

&end = " hide message no-pause. "
}
                                  

/*
for each kdlonkl where (kdlonkl.bank = s-ourbank or s-ourbank = "TXB00") and kdlonkl.kdcif = s-kdcif 
                     and kdlonkl.kdlon = s-kdlon no-lock.
   v-rat = v-rat + kdlonkl.rating.
end.
find current kdlon exclusive-lock no-error.
if v-rat <= 1 then kdlon.lonstat  = '01'.
if v-rat > 1 and  v-rat <= 2 then  kdlon.lonstat = '02'.
if v-rat > 2 and  v-rat <= 3 then  kdlon.lonstat = '04'.
if v-rat > 3 and  v-rat <= 4 then  kdlon.lonstat = '06'.
if v-rat > 4 then kdlon.lonstat  = '07'.
find current kdlon no-lock no-error.
*/


                                                                                                                     
function defdata returns char (p-spr as char, p-value as char).
  def var vp-param as char.
  if p-spr = "" then vp-param = trim(p-value).
  else do:
    find bookcod where bookcod.bookcod = p-spr and bookcod.code = p-value no-lock no-error.
    if avail bookcod then vp-param = trim(bookcod.name).
  end.
  return vp-param.
end.

function defdata1 returns decimal (p-spr as char, p-value as char).
  def var vp-rat as deci.
  if p-spr = "" then vp-rat = 0.
  else do:
    find bookcod where bookcod.bookcod = p-spr and bookcod.code = p-value no-lock no-error.
    if avail bookcod then vp-rat = deci(trim(bookcod.info[1])).
  end.
  return vp-rat.
end.

procedure prat.
   def input parameter v-cod as char.
   def var v-param as char.
   def var v-rat as decimal.
   
   find first kdlonklh where  kdlonklh.kdcif = s-kdcif and kdlonklh.nom = s-nom 
                             and kdlonklh.kod = v-cod no-lock no-error.
   find first kdklass where kdklass.kod = kdlonklh.kod no-lock no-error.
   if avail kdlonklh and avail kdklass then do:
     v-param = defdata (kdklass.sprav, kdlonklh.val1).
     v-rat = defdata1 (kdklass.sprav, kdlonklh.val1).
  
     find current kdlonklh exclusive-lock no-error.
     kdlonklh.valdesc = v-param.
     kdlonklh.rating = v-rat.
     find current kdlonklh no-lock no-error.
   end. 
end.

procedure plong.
   def input parameter v-cod as char.
   def var v-param as char.
   def var v-rat as decimal.

   find first kdlonklh where  kdlonklh.kdcif = s-kdcif and kdlonklh.nom = s-nom  
                             and kdlonklh.kod = v-cod no-lock no-error.
   find first kdklass where kdklass.kod = kdlonklh.kod no-lock no-error.
          
   if avail kdlonklh and avail kdklass then do:
   find bookcod where bookcod.bookcod = 'kdlong' and bookcod.code = '02' no-lock no-error.
      if avail bookcod then assign v-param = bookcod.name 
                                   v-rat = deci(trim(bookcod.info[1])). 

     find current kdlonklh exclusive-lock no-error.
     kdlonklh.valdesc = v-param.
     kdlonklh.rating = deci(kdlonklh.val1) * v-rat.
     find current kdlonklh no-lock no-error.
   end.
end.
