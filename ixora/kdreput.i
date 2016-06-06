/* kdreput.i
 * MODULE
        ЭКД 
        ЭКД - Электронное кредитное досье
 * DESCRIPTION
        Репутация заемщика
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
        01.03.2005 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/



if s-kdcif = '' then return.

find {2} where  {2}.kdcif = s-kdcif and {4} and ({2}.bank = s-ourbank or s-ourbank = "TXB00") 
     no-lock no-error.

if not avail {2} then do:
  message skip " Клиент N" s-kdcif "не найден !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


def var v-cod as char.
def var v-descr as char format "x(30)".
define var v-info as char.

define frame fr skip(1)
       {1}.resume    label "Репутация    " help " F2 - справочник"
           validate ({1}.resume <> "msc" and can-find (bookcod where bookcod.bookcod = "kdreput" and 
              bookcod.code = {1}.resume no-lock), " Неверный код ! Выберите из справочника")
           v-descr no-label skip(1)
       {1}.info[1]   label "Основание    " VIEW-AS EDITOR SIZE 50 by 8 skip(1)
       {1}.whn       label "ПРОВЕДЕНО " {1}.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "РЕПУТАЦИЯ ЗАЕМЩИКА " .

on help of {1}.resume in frame fr do: 
  v-cod = {1}.resume.
  run uni_book ("kdreput", "*", output v-cod).  
  {1}.resume = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdreput" and bookcod.code = v-cod no-lock no-error.
    if avail bookcod then v-descr = bookcod.name. 
    displ {1}.resume v-descr with frame fr.
end.

define var v-sel as char.

define variable s_rowid as rowid.

  find first {1} where {1}.kdcif = s-kdcif and {3} and {1}.code = '12' and ({1}.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if not avail {1} then do:
     if s-ourbank = {2}.bank then do:
        create {1}. 
        {1}.bank = s-ourbank. {1}.code = '12'.  
        {1}.kdcif = s-kdcif. {3}. {1}.who = g-ofc. {1}.whn = g-today.
        find current kdaffil no-lock no-error.
     end.
     else do:
       message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
       return.
     end.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.


  find bookcod where bookcod.bookcod = "kdreput" and bookcod.code = {1}.resume no-lock no-error.
    if avail bookcod then v-descr = bookcod.name. 
                     else v-descr = ''.
 
  if s-ourbank = {2}.bank then do:
    displ {1}.resume v-descr {1}.info[1] {1}.who {1}.whn with frame fr .
    find current {1} exclusive-lock no-error.
    update {1}.resume {1}.info[1] with frame fr.
    {1}.who = g-ofc. {1}.whn = g-today.
    find current {1} no-lock no-error.
  end.
  else do:
    displ {1}.resume v-descr {1}.info[1] {1}.who {1}.whn  with frame fr.
    pause.
  end.

hide message.


            

