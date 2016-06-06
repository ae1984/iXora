/* pkinet.p
 * MODULE
        ПотребКРЕДИТ
 * DESCRIPTION
       Печать интернет анкеты
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-x-4-1
 * AUTHOR
        16.05.2005 nadejda
 * CHANGES
*/

{global.i}
{pk.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and 
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def new shared temp-table t-anks
  field ln like pkanketa.ln
  field rnn like pkanketa.rnn
  field rating like pkanketa.rating
  index ln is primary unique ln
  index rnn rnn.

create t-anks.
assign t-anks.ln = pkanketa.ln
       t-anks.rnn = pkanketa.rnn
       t-anks.rating = pkanketa.rating.

run pkankvwi ("АНКЕТНЫЕ ДАННЫЕ ИНТЕРНЕТ").

message skip " Документ открыт в новом окне !"
  skip(1) view-as alert-box buttons ok title " ВНИМАНИЕ ! ".


