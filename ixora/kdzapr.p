/* kdzapr.p Электронное кредитное досье

 * MODULE
        Название Программного Модуля
 * DESCRIPTION
       Ввод занных в досье - запрашиваемые клиентом данные
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3 Запрос 
 * AUTHOR
        24.07.03 marinav
 * CHANGES
        30/04/2004 madiar - Запрет изменения запрашиваемых условий при просмотре досье филиалов в ГБ
        14/05/2004 madiar - Если условия вводятся в данный момент на другом терминале - вообще не заходит в режим редактирования.
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}
{kdlon.f}

/*s-kdlon = 'KD11'.
*/
def var v-cod as char.

if s-kdlon = '' then return.

find kdlon where  kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if s-ourbank <> kdlon.bank then return.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if kdlon.sts > "01" then do:
  message skip " Менять сумму нельзя !" skip(1)
    view-as alert-box buttons ok .
  return.
end.

form kdlon.repayz VIEW-AS EDITOR SIZE 40 by 3 
 with frame y  overlay  row 14  centered top-only no-label.

 {kdlonvew.i}


on help of kdlon.type_lnz in frame kdlon do: 
  v-cod = kdlon.type_lnz.
  run uni_book ("kdfintyp", "*", output v-cod).  
  kdlon.type_lnz = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-insdescr = bookcod.name. 
    displ kdlon.type_lnz v-insdescr with frame kdlon.
end.

/*on help of kdlon.repayz in frame kdlon do: 
  v-cod = kdlon.repayz.
  run uni_book ("kdrepay", "*", output v-cod).  
  kdlon.repayz = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-repdescr = bookcod.name. 
    displ kdlon.repayz v-repdescr with frame kdlon.
end.

on help of kdlon.repay%z in frame kdlon do: 
  v-cod = kdlon.repay%z.
  run uni_book ("kdrepay", "*", output v-cod).  
  kdlon.repay%z = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-rep%descr = bookcod.name.
    displ kdlon.repay%z v-rep%descr with frame kdlon.
end.
*/

on help of kdlon.goalz in frame kdlon do:
   run h-codfr ("lntgt", output v-cod).
   kdlon.goalz = v-cod.
   displ kdlon.goalz with frame kdlon.
end.

find current kdlon exclusive-lock.
update kdlon.type_lnz kdlon.amountz kdlon.crcz kdlon.ratez 
       kdlon.srokz kdlon.goalz  with frame kdlon.
update kdlon.repayz with frame y scrollable.
hide frame y no-pause. 
update kdlon.repay%z with frame kdlon.
find current kdlon no-lock.
  


