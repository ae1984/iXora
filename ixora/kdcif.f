/* kdcif.f  
 * MODULE
     Электронное кредитное досье
 * DESCRIPTION
      Форма для заведения нового клиента в ЭКД
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
      20.05.2003 marinav
 * CHANGES
      18.08.2003 marinav поменян формат некоторых полей
      30.09.2005 marinav - изменения для бизнес-кредитов
      11.09.2008 galina - добавила validate для поля lnopf
      23.02.2009 galina - значение поля lnopf не может быть msc
*/

def var v-stsdescr as char.
def var v-lnopf as char.
def var v-ecdivis as char.
def var msg-err as char.

function chk-prefix returns logical (p-value as char).
  if p-value = "" then do:
    message skip "Вы уверены, что у данного клиента ОТСУТСТВУЕТ организац.-правовая форма?" skip(1)
      view-as alert-box button yes-no title " ВНИМАНИЕ! " update v-ch as logical.
    if not v-ch then
      msg-err = "Введите организационно-правовую форму юридического лица !".
    return v-ch.
  end.
  if not can-find(codfr where codfr.codfr = "ownform" and codfr.code = p-value and 
        codfr.code <> "msc" no-lock) then do:
    message skip
         " Введенное краткое название организационно-правовой формы " skip
         " НЕ НАЙДЕНО В СПРАВОЧНИКЕ !" skip(1)
         " Добавить в справочник новое значение ? " skip(1)
         view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice as logical.
    if v-choice then do:
      create codfr.
      codfr.codfr = "ownform". 
      codfr.level = 1.
      codfr.code = p-value.
      return true.
    end.
    else do:
      msg-err = "Нет такого кода в справочнике организационно-правовых форм !".
      return false.
    end.
  end.
  return true.
end.


form
  s-kdcif label "КОД КЛИЕНТА" 
    help " F2 - поиск"
    colon 15
/*    kdcif.type colon 35  label "ТИП "*/
  kdcif.mname colon 32 label "КАТЕГ"
          help " Категория клиента (F2 - справочник)"

  kdcif.manager format "x(2)" colon 44 label "ТИП"
          help " Юр лцо, физ лицо, ЧП (F2 - справочник)"
   
  kdcif.bank format "x(6)" label "БАНК" colon 57 skip

  kdcif.rnn label "РНН" colon 15 
  kdcif.regdt label "РЕГИСТ" colon 57 
  kdcif.who no-label colon 69 skip  

  kdcif.prefix  label "ФОРМА СОБСТВ" FORMAT "x(6)" help " F2 - справочник организационно-правовых форм "
     validate(chk-prefix(kdcif.prefix), msg-err) colon 15

  kdcif.name label "ПОЛН НАИМ" colon 15 skip
  kdcif.fname label  "КРАТ НАИМ" colon 15 skip
  kdcif.lnopf   LABEL "ОРГ-ПРАВ ФОРМА" help "F2 - справочник" validate(kdcif.lnopf <> "" and kdcif.lnopf <> 'msc' and can-find(codfr where codfr.codfr = "lnopf" and codfr.code = kdcif.lnopf no-lock),'Неверная организацинно-правовая форма!') colon 15 v-lnopf no-label format 'x(30)' colon 25 skip 
  kdcif.ecdivis LABEL "ОТРАСЛЬ" colon 15 v-ecdivis no-label format 'x(30)' colon 25 skip

  kdcif.urdt LABEL "ДАТА РЕГИСТ" colon 15 kdcif.urdt1 LABEL "ДАТА ПЕРВ РЕГИСТ" colon 57 skip
  kdcif.regnom LABEL "РЕГ НОМЕР" colon 15 skip
  kdcif.addr[1] LABEL "ЮРИД АДРЕС" colon 15 skip
  kdcif.addr[2] LABEL "ФАКТ АДРЕС" colon 15 skip
  kdcif.tel LABEL "ТЕЛЕФОНЫ" colon 15 
  kdcif.sotr LABEL "КОЛ-ВО СОТР" colon 57 skip

  kdcif.chief[1] LABEL "РУКОВОДИТЕЛЬ" format "x(50)" colon 15 skip
  kdcif.job[1]   LABEL "ДОЛЖНОСТЬ" format "x(50)" colon 15 skip
  kdcif.docs[1]  LABEL "НОМЕР ДОК" format "x(50)" colon 15 skip
  kdcif.rnn_chief[1] LABEL "РНН РУК-ЛЯ"colon 15 skip
  kdcif.chief[2] LABEL "ГЛ. БУХГАЛТЕР" format "x(50)" colon 15 skip

  with centered row 3 width 80 side-labels frame kdcif.

