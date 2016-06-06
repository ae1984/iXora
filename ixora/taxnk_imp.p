/*taxnk_imp .p
 * MODULE
        Название модуля
 * DESCRIPTION
        Загрузка из файла справочника Налоговых комитетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25/11/2008 galina
 * BASES
        BANK COMM
 * CHANGES
*/

def input parameter p-file as char.
def var v-text as char.
 for each taxnk:
  delete taxnk.
 end.
 input from value(p-file).
 repeat:
  import unformatted v-text.
  int(trim(substr(entry(1,v-text),1,8))) no-error.
  if error-status:error then do: 
    message "Не верный формат сообщения - " + v-text + "!".
    next.
  end.  
  create taxnk.
  assign
     taxnk.bank = "TXB99"
     taxnk.rnn = trim(entry(1,v-text))
     taxnk.name = trim(entry(2,v-text))
     taxnk.iik = 000080900
     taxnk.bik = 195301070
     taxnk.kod = "14"
     taxnk.Kbe = "11"
     taxnk.Knp = "911"
     taxnk.symb  = 260
     taxnk.comgl = 460714.
     if trim(entry(2,v-text)) begins "НД" then 
     taxnk.typegrp = 1.
     if trim(entry(2,v-text)) begins "НУ" then  
     taxnk.typegrp = 2.   
 end.