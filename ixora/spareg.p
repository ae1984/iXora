/* spareg.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Формирование внешних платежей по зарплатным файлам и отправка их по маршруту

        Соглашения :
        1. Новые файлы с пенсионными платежами должны быть с именем SP------
           В sysc = "zpdir" дирректория для зарплатных платежей
        2. Обработанные зарплатные платежи переименовываются RMZ-------.SP------
           В sysc = "zparc" дирректория для обработанных зарплатных платежей
        3. Подготовленные файлы для отправки в КЦ должны быть RMZ------- , что
           соответствует их электронному документу в платежной системе
           В sysc = "zpin" дирректория для подготовленных к отправке
           зарплатных платежей
        4. После времени окончания клиринга офицеру выдается запрос на изменение 2-й даты валютирования
           sysc = "zptim" - настройка, после какого времени выдавать запрос
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        19.09.2012 Lyubov
 * BASES
        BANK
 * CHANGES
        27.09.2012 Lyubov - дописала в шапку BASES
*/



 {global.i}

 def var method-return as logical.
 def var j as int .

 def var i as int .
 def var v-dir  as cha .
 def var n-buf AS CHA .
 DEF new shared VAR V-OK AS LOG .
 def var exitcod as cha initial "" .
 def var v-err as cha format "x(78)" .
 def var yn as log .
 def var v-viewdt2 as logical.
 def var v-chngdt2 as logical.
 def var num as cha extent 20 .
 def new shared var v-inf as cha .
 def new shared var f-name as cha .
 def new shared var iui as int .
 def new shared var tot-sum like remtrz.amt .
 def new shared var n-pap as int .
 def new shared var n-sum like remtrz.amt .
 def var list-name as cha .
 def var v-cls as date .
 def var lbnum as int .
 def var v-unidir as cha .
 def var v-uniarh as cha .
 def new shared var v-lbin as cha .
 def new shared var v-lbina as cha .
 def new shared var v-lbeks as cha .
 def new shared var v-lbhst as cha .
 def new shared var s-remtrz like remtrz.remtrz.
 def var v-maxf as integer init 400.
 def var v-kolf as integer init 0.
 def var v-ret as char.
 def var RetBuf as char.
 def new shared var who_cre as char.

 def var v-name as cha  view-as selection-list
  INNER-CHARS 30 INNER-LINES 10 .
 def var v-narc as cha view-as selection-list
   INNER-CHARS 30 INNER-LINES 10 .

 def var v-tar as cha view-as selection-list
  INNER-CHARS 50 INNER-LINES 12 SORT  .
 def frame ftar v-tar  with title  f-name  no-label column 10 row 3 .

 def frame fhelp "<V> - view  <I> - import   <a> - all import   "
  with row 18 column 4 no-box .

{lgps.i new}

m_pid = "ZP".

find sysc where sysc.sysc = "zpdir" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record ZPDIR in sysc file !! ".
 message v-text . pause 10.
 run lgps.
 return .
end.

v-lbin = sysc.chval.

find sysc where sysc.sysc = "zparc" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record ZPARC in sysc file !! ".
 message v-text . pause 10.
 run lgps.
 return .
end.
v-lbina = sysc.chval.

if v-lbin = v-lbina then do :
 v-text = " ERROR !!! Records ZP and ZPARH are equal !! ".
 message v-text . pause 10.
 run lgps.
 return .
end .

find sysc where sysc.sysc = "zpin" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
 v-text = " ERROR !!! There isn't record ZPIN in sysc file !! ".
 message v-text . pause 10.
 run lgps.
 return .
end.
v-unidir = sysc.chval.

def temp-table t-qarc
    field fname as char.

def new shared temp-table t-qin
    field fname as char.

def query qarc for t-qarc.
def query qin  for t-qin.

def browse barc
    query qarc no-lock
    display
        t-qarc.fname  format "x(35)"
    with 10 down width 38 title "Обработанные зарплатные платежи" no-labels.

def browse bin
    query qin no-lock
    display
        t-qin.fname  format "x(35)"
    with 10 down width 34 title "Новые зарплатные платежи" no-labels.

def frame farcch
    barc help ""
  with column 40  no-label  row 2.

def frame fin
    bin help ""
  with column 4  no-label  row 2.
/*-----------------------------------------------*/



/* очистка директории ARC если там больше 400 файлов  */
def var filestr as char.
{comm-dir.i}
run comm-dir (v-lbina, "", FALSE).

v-kolf = integer (return-value).
run chek-arx.
v-ret = return-value.

/* очистим список comm-dir */
run comm-cleardir.

if  v-ret <> "0" then return.
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

/* формирование названия каталога незагруженных пенсионных файлов */
{get-dep.i}
def var v-rkoall as char init "".
def var v-drkoall as char init "".
def var v-depart as integer.
def var v-rko as integer init 0.

v-depart = get-dep(g-ofc, g-today).
if v-depart <> 1 then do:
  find sysc where sysc.sysc = "RCOZP" no-lock no-error.
  if avail sysc and sysc.chval <> "" and num-entries(sysc.chval, ";") > 1 then do:
    v-rkoall = entry(1, sysc.chval, ";").
    v-drkoall = entry(2, sysc.chval, ";").
  end.

  if v-rkoall <> "" then do:
    v-rko = lookup(string(v-depart), v-rkoall).
    if v-rko > 0 and entry(v-rko, v-drkoall) <> "0" then do:
      if substr(v-lbin, length(v-lbin), 1) <> "/" then v-lbin = v-lbin + "/".
      v-lbin = v-lbin + "RCO" + entry(v-rko, v-drkoall)  + "/".
    end.
  end.
end.

v-cls = g-today .

on tab of barc in frame farcch do:
 disable barc with frame farcch.
 enable bin with frame fin.
end.

on tab of bin in frame fin do:
 disable bin with frame fin.
 enable barc with frame farcch.
end.



on any-printable of barc in frame farcch do:
     do j = barc:NUM-SELECTED-ROWS TO 1 by -1 transaction:
        method-return = barc:FETCH-SELECTED-ROW(j).
        GET CURRENT qarc NO-LOCK.
        find current t-qarc.
     end.

     if keylabel(lastkey) = "v" then do:
       v-dir = v-lbina .
       f-name = entry(1,t-qarc.fname," ").
       unix value("joe -rdonly  " + v-dir + "/" + f-name ) .
     end.
end.

on any-printable of bin in frame fin do:
  do j = bin:NUM-SELECTED-ROWS TO 1 by -1 transaction:
     method-return = bin:FETCH-SELECTED-ROW(j).
     GET CURRENT qin NO-LOCK.
     find current t-qin.
  end.
  if keylabel(lastkey) = "v" then  do:
    v-dir = v-lbin .
    f-name = entry(1,t-qin.fname," ").
    unix value("joe -rdonly  " +
                v-lbin + entry(1,t-qin.fname," ")) .
  end.

  if keylabel(lastkey) = "i" then do:
    f-name = entry(1,t-qin.fname," ").
    if substr(f-name,10,3) = "log" then return .

    Message skip " Обработать платеж ?" skip(1) view-as alert-box button yes-no title "" update yn .
    if yn then do:
      if not (f-name matches "SP*")  then do:
        Message skip " Файл не зарплатный платеж !" skip(1) view-as alert-box button ok title " ОШИБКА ".
        return .
      end.


/**/
      v-kolf = v-kolf + 1.
      repeat:
        run chek-arx.
        if return-value = "0" then leave.
      end.
/**/

      /*------------------------------------------------------------------------*/
      RetBuf = "".
      input through ls -la value(v-lbin + f-name).
      import unformatted RetBuf.
      if RetBuf <> "" and index(RetBuf,"id") > 0 then who_cre = substr(RetBuf,index(RetBuf,"id"),7).
      else who_cre = "".
      /*------------------------------------------------------------------------*/

      v-ok = false .
      unix silent value("/bin/mv " + v-lbin + "/" + f-name + " " + v-lbina + "/" + f-name ) .
      pause 0.
        run ZP_ps (input-output v-viewdt2, input-output v-chngdt2).
      pause 0 .

      if v-ok then do:
        unix silent value("/bin/cp " + v-lbina + "/" + f-name + " " + v-unidir + "/" + CAPS(s-remtrz) + " && " + /* 03.10.2006 u00121  если эта команда не выполнится, то не выполнится и следующая*/
		          "/bin/mv " + v-lbina + "/" + f-name + " " + v-lbina +  "/" + CAPS(s-remtrz) + "." + f-name ) . pause 0.

        hide message no-pause.
        Message " Зарплатный платеж обработан "  . pause 3.
      end.
      else do:
        unix silent value("/bin/mv " + v-lbina + "/" + f-name + " " + v-lbin + "/" + f-name ) . pause 0.
        Message skip " Ошибка в обработке ..." skip(1) view-as alert-box button ok title " ОШИБКА ".
      end.
    end.
  end.


  if keylabel(lastkey) = "a" then do:
    f-name = entry(1,t-qin.fname," ").
    if substr(f-name,10,3) = "log" then return .

    Message skip " Обработать все платежи ?" skip(1) view-as alert-box button yes-no title "" update yn .
    if yn then do:
      if not (f-name matches "SP*")  then do:
        Message skip " Файл не зарплатный платеж !" skip(1) view-as alert-box button ok title " ОШИБКА ".
        return .
      end.

      else do:
        v-viewdt2 = yes.
        v-chngdt2 = no.

        for each t-qin:

          if entry(1,entry(1,t-qin.fname)," ") matches "SP*" then
             f-name = entry(1,entry(1,t-qin.fname)," ").
             v-kolf = v-kolf + 1.
          repeat:
            run chek-arx.
            if return-value = "0" then leave.
          end.

          /*------------------------------------------------------------------------*/
          RetBuf = "".
          input through ls -la value(v-lbin + f-name).
          import unformatted RetBuf.
          if RetBuf <> "" and index(RetBuf,"id") > 0 then who_cre = substr(RetBuf,index(RetBuf,"id"),7).
          else who_cre = "".
          /*------------------------------------------------------------------------*/

          v-ok = false .
          unix silent value("/bin/mv " + v-lbin + "/" + f-name + " " + v-lbina + "/" + f-name ) . pause 0.

          run ZP_ps (input-output v-viewdt2, input-output v-chngdt2).

          if v-ok then do:
            unix silent value("/bin/cp " + v-lbina + "/" + f-name + " " + v-unidir + "/" + CAPS(s-remtrz) + " && " + /*03.10.2006 u00121  если эта команда не выполнится, то не выполнится и следующая*/
            		      "/bin/mv " + v-lbina + "/" + f-name + " " + v-lbina + "/" + CAPS(s-remtrz) + "." + f-name ) . pause 0.
          end.
          else do:
            unix silent value("/bin/mv " + v-lbina + "/" + f-name + " " + v-lbin + "/" + f-name ) . pause 0.
            Message skip " Ошибка в обработке ..." skip(1) view-as alert-box button ok title " ОШИБКА ".
          end.
        end.
        if v-ok then
          Message skip " Платежи обработаны !" skip(1) view-as alert-box button ok title "".
      end.
    end.
  end.
end.


repeat :

  num = "" .
  list-name = "" .
   for each t-qin: delete t-qin. end.

  input through value("~{ ls -lt " + v-lbin + "SP*;~}"  + " 2> /dev/null" ) .

  repeat :
    import num .
     create t-qin.
     t-qin.fname = substr(num[9],length(v-lbin) + 1 ) + " " + num[6] + " " + num[7] + " " + num[8].
  end.
  input close.

 input through value("/bin/ls -lt " + v-lbina + "/" + "*" + " 2> /dev/null" ) .
  for each t-qarc: delete t-qarc. end.
  repeat :
    import num .
     create t-qarc.
     t-qarc.fname = substr(num[9],length(v-lbina + "/") + 1 ) + " " +  num[6] + " " + num[7] + " " + num[8].
  end.
  input close .

   open query qarc for each t-qarc.
   open query qin for each t-qin.
   apply "VALUE-CHANGED" to BROWSE barc.
   apply "VALUE-CHANGED" to BROWSE bin.

  view frame farcch.
  view frame fin.
  view frame fhelp.
  pause 0 .

  enable bin with frame fin.
  enable barc with frame farcch.

  wait-for close of this-procedure
       or any-printable of bin in frame fin
       or any-printable of barc in frame farcch
       focus bin pause 5.

  disable bin with frame fin.
  disable barc with frame farcch.

  yn = no.
end.

procedure chek-arx.
  if v-kolf >= v-maxf then do:
    displ "Подождите. Идет архивация платежей..." with row 7 centered overlay frame frarch.

    find sysc where sysc.sysc = "zp2ar" no-lock no-error.
    if not sysc.loval then do:
      find current sysc exclusive-lock.
      sysc.loval = yes.
      find current sysc no-lock.

      filestr = "zp" + string(day(g-today), "99") + "-" + string(month(g-today), "99") + "-" +
                        substr(string(year(g-today), "9999"), 3, 2) + "-" + string(time).
      unix silent value ("tar cvf " + filestr + ".tar" + " " + v-lbina + "* > /dev/null").
      unix silent value ("gzip -9 " + filestr + ".tar > /dev/null").
      unix silent value ("mv " + filestr + ".tar.gz" + " " + v-lbin + "ARCZP/  > /dev/null").
      unix silent value ("rm -f " + v-lbina + "*").
      unix silent value ("rm -f zparxs.lst").

      find current sysc exclusive-lock.
      sysc.loval = no.
      find current sysc no-lock.

      v-kolf = 0.

      hide frame frarch.
      return "0".
    end.
    else do:
      pause 10.
      hide frame frarch.
      return "1".
    end.
  end.
  else return "0".
end.