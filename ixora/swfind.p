/* swfind.p

 * MODULE
        
 * DESCRIPTION
        Поиск бика банка в локальной базе
 * RUN
        Способ вызова программы, описание параметров, примеры вызова 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM       
 * AUTHOR
        05.05.2010 k.gitalov 
 * CHANGES
        
*/

define input        parameter bankbic as char format "x(13)".
define input-output parameter result  as logical.
define input-output parameter mesg    as char.

if not result then do:
 mesg = "".
 result = false.
 return.
end.
if length(bankbic) < 3 then do:
  mesg = "Для нахождения бика введите не менее 3х символов".
  result = false.
  return.
end.

 
def var biclist as char init "".
def var selbic as char  init "".
def buffer b-swbik for comm.swibic.
def var I as int init 0.

  for each b-swbik where b-swbik.bic MATCHES(bankbic + "*") no-lock:
   I = I + 1.
   if biclist <> "" then biclist = biclist + "|".
   biclist = biclist + b-swbik.bic.
  end.
  
  case I:
    when 0 then do:
      mesg = "Бик " + bankbic + " не найден в базе! ".
      result = false.
    end.
    when 1 then do:
         find first b-swbik where b-swbik.bic = biclist no-lock no-error.
         mesg = string(biclist,"x(35)").
         mesg = mesg + string(b-swbik.name,"x(35)").
         mesg = mesg + string(b-swbik.city + " " + b-swbik.cnt,"x(35)").
         result = true.
    end.
    OTHERWISE do:
       run sel1("Выберите бик", biclist).
       selbic = return-value.
       if selbic <> "" then 
       do:
         find first b-swbik where b-swbik.bic = selbic no-lock no-error.
         mesg = string(selbic,"x(35)").
         mesg = mesg + string(b-swbik.name,"x(35)").
         mesg = mesg + string(b-swbik.city + " " + b-swbik.cnt,"x(35)"). 
         result = true.
       end.
       else do:
         mesg = "".
         result = false.
       end.
    end.
  end case.
  
 release b-swbik.
 
return.   
           
   
