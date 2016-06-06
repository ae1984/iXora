/* ps-rej.p
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
  {lgps.i}

  def input param pi1 like reject.ref.
  def input param pi2 like reject.t_sqn.
  def input param pi3 as character.
  def output param v-er as char.
  def var exitcod as cha .
  def var v-sqn as cha .
  def var buf as cha extent 100 .
  def var i as int .
  def var n as int .


 find first sysc where sysc.sysc = "M-DIR" no-lock no-error .

 if not avail sysc then do:
  v-text = " Записи M-DIR нет в sysc файле " .  run lgps.
  return .
 end.

 find reject where reject.ref = pi1 no-lock no-error.
 if available reject then do :
   v-text = " Повторное отвержение. Запись " + pi1 +  
   " уже находится в файле отверженных сообщений .".
   v-er = "0".
 end.

 else do :
  output to value( sysc.chval + "/" + pi2 + ".rej") .

  put unformatted
  "\{1:xxxXXXXXXXXXXXXxxxxXXXXXX\}\{2:E11FXXXXXXXXXXXXxXxxx\}\{4:" chr(13)
  chr(10)
  ":21:" pi1
       chr(13) chr(10)
  ":75:" .
  if v-text = "" then put unformatted  chr(13) chr(10).
  else do:
  n = 1.
  repeat while substr(v-text,n,60) <> "" :
    put unformatted substr(v-text,n,60)  chr(13) chr(10).
    n = n + 60.
  end.
  end .

  put unformatted "-}" .
  output close .

   v-text = " Сообщение об отвержении отправлено  " + pi1 + " -> " + 
   trim(pi2) + ".rej " + trim(pi3).

  input through
   value( "lsend -v - " + pi3 + " < " + sysc.chval + "/" +
   pi2 + ".rej " + " ; echo $? " ) .

  v-sqn = "".
  repeat:
   import buf .
   exitcod = buf[1].
   if exitcod = "verbose:" and v-sqn = ""  then v-sqn = buf[3] .
  end.

 if  exitcod ne "0"  or v-sqn = "" then do:

  do i = 1 to 100 .
   if buf[i] ne "" then
   v-text = v-text + " " + buf[i]  .
  end.

     v-text =
     " ОШИБКА ОТПРАВКИ В LASKA ДЛЯ  " + trim(pi1) + " " + trim(pi3) +
     " " + v-text .
     v-er = "1".
   end.

   else do :
       create reject .
       reject.ref = pi1 .
       reject.t_sqn = pi2 .
       reject.whn = today.
       reject.who = g-ofc.
       reject.tim = time.
       v-text = v-text + " Laska SQN = " + v-sqn .
       v-er = "0".
   end.
end.
    run lgps.
