/* nmenu.p
 * MODULE
        Главное меню
 * DESCRIPTION
        Собственно показ главного меню и запуск программ
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        11.11.2003 nadejda - проверка на устаревание пароля, если больше 30 дней, то запросить смену пароля
        13.12.2003 nadejda - поставила no-lock во всех циклах и поисках
        17.12.2003 nadejda - логирование ошибок входа переведено в каталог /data/log
        11.05.2004 sasco   - завел в SYSC переменную MANDIR для мануалов по пунктам меню
        24.05.2004 suchkov - закомментарил кусок кода где производилась запись в таблицу ofc
        20.08.2004 sasco   - Ctrl+F - поиск по названию
        23.08.2004 sasco   - Добавление рекурсивных пакетов доступа
        25/07/2007 madiyar - убрал ссылку на удаленную таблицу menu
        21/02/2008 madiyar - подправил под новый размер терминала
	12/11/2008 id00363 - поменял g-today на today в заголовке
*/



{mainhead.i MENU "new global"}

g-proc = "nmenu".

define buffer b-nmenu for nmenu.

define var v-father like nmenu.father initial "MENU".
define var v-entry  like nmenu.father initial "MENU".
define var v-stack  as cha initial "MENU" no-undo.
define var v-lnstack as cha no-undo.
define var v-ln     as int initial 1.
define var v-tmpln  as int.
define var v-lnproc as log.
define var v-time   as cha format "x(8)".
define var v-max    as int.
define var v-pos    as int.
define var v-ifname as cha.
define var v-sts    as cha format "x(23)" label "S".
define var v-func   as cha.
define var v-first  as log.
def var v-logdir as char.

def var dat1 as date.
def var dat5 as date.
def var vpass like ofc.pass.
def var vencpass like ofc.pass.
def var venctab as cha format "x" extent 15.
def var vmno as integer format "zz".
def var vcnt as int init 1.
def var vpkg as cha format "x(23)".
def var vdisdes  as char extent 34 format "x(33)" label "DESCRIPTION".
def var vdismgrp as char extent 34 format "x(4)" label "GROUP".
def var f-prc as char.

{nmenu.f}

/** SASCO FOR RU **/
/* ПОИСК ПО МЕНЮ */
on return of browse bt do:
   if not avail tmen then leave.
   g-fname = tmen.fname.
   apply "enter-menubar" to frame ft.
end.

define variable ofc_stack as character. /* стэк для поиска прав - какие пакеты просмотрели, */
                                        /* чтобы избежать циклических ссылок */

function nmenu_check_permis returns logical (wofc as character, wfather as character).

   define variable ggi as integer.
   define variable wpar as character.
   define variable wlog as logical.

   wlog = no.

   find ofc where ofc.ofc = wofc no-lock no-error.
   if not avail ofc then return no.

   if lookup (wofc, ofc_stack) > 0 then return no.
   wpar = trim(ofc.expr[1]).

   find sec where sec.ofc eq wofc and sec.fname eq wfather no-lock no-error.
   if avail sec then return yes.

   ofc_stack = ofc_stack + "," + wofc.
   do ggi = 1 to num-entries (wpar):
      find ofc where ofc.ofc = entry(ggi, wpar) no-lock no-error.
      if not avail ofc then next.
      if not wlog then wlog = nmenu_check_permis (entry(ggi, wpar), wfather).
   end.
   return wlog.
    
end function.

procedure nmenu_findmenu.
    
    define variable tdepth as character.

    vtmenmode = true.
    do on endkey undo, leave:
    for each tmen: delete tmen. end.
    vtmen = "*" + trim(vtmen) + "*".
    vtmen = replace (vtmen, "**", "*").
    for each nmdes where nmdes.lang = g-lang and
                         nmdes.des matches vtmen
                         no-lock:
        find nmenu where nmenu.fname = nmdes.fname no-lock no-error.
        if not avail nmenu then next.
        if nmenu.link = "" and nmenu.proc = "" then next.
        run menudepth ("", nmenu.fname, output tdepth).
        if tdepth = ? then next.
        create tmen.
        tmen.fname = nmdes.fname.
        tmen.des = nmdes.des.
        tmen.depth = tdepth.
    end.
    open query qt for each tmen.
    enable all with frame ft.
    wait-for window-close of current-window or enter-menubar of frame ft focus browse bt.
    hide frame ft. pause 0.
    end.
    if lastkey = keycode ("PF4") then g-fname = "".

end procedure.


/** SASCO FOR RU **/
/* ПОИСК ПО ДЕРЕВУ */
/*
on return of browse btr do:
   if not avail tmen then leave.
   g-fname = tmen.fname.
   apply "enter-menubar" to frame ftr.
end.
*/
procedure nmenu_findtree.
    
    define variable tdepth as character.
    define variable tfather as character.
    define variable treal as character.
    define variable ti as integer.
    
    if frame-value = "" then return.
    g-fname = "".

    for each tmen: delete tmen. end.

    tdepth = trim(frame-value).
    tfather = v-father.
    do while true:
       if tfather = "MENU" then leave.
       find nmenu where nmenu.fname = tfather no-lock no-error.
       tfather = nmenu.father.
       tdepth = trim(string (nmenu.ln)) + "," + tdepth.
    end.

    tfather = "MENU".
    treal = "".
    do ti = 1 to num-entries (tdepth):
       find nmenu where nmenu.father = tfather and nmenu.ln = integer (entry (ti, tdepth)) no-lock no-error.
       find nmdes where nmdes.fname = nmenu.fname and nmdes.lang = g-lang no-lock no-error.
       treal = treal + entry(ti,tdepth) + ".".
       create tmen.
       assign tmen.dlen = string(ti)
              tmen.depth = treal
              tmen.des = FILL (" ", (ti - 1) * 2 + 1) + nmdes.des
              tmen.fname = nmenu.fname.
       tfather = nmenu.fname.
    end.

    vtmenmode = true.
    open query qtr for each tmen.
    enable all with frame ftr.
    wait-for window-close of current-window or enter-menubar of frame ftr focus browse btr.
    hide frame ftr. pause 0.

    if lastkey = keycode ("PF4") then g-fname = "".

end procedure.

vpkg = "PLATON Ver 1.00".
{os-test.i}

find sysc where sysc.sysc = "LICEND" no-lock no-error.
if not avail sysc then do:
  bell. {mesg.i 9214}.
  pause 5.
  quit.
end.

if g-today > sysc.daval then do:
  bell.
  view frame callims1.
  pause 5.
  quit.
end.

v-logdir = trim(OS-GETENV("DBLOGDIR")).
if v-logdir = "" then v-logdir = g-dbdir.


if g-today >= sysc.daval - 5 then do:
  bell.
  display sysc.daval with frame callims2.
  pause 3.
end.
find sysc where sysc.sysc = 'BEGDAY' no-lock no-error.
if available sysc and sysc.daval <> ? then
dat1 = sysc.daval.
find sysc where sysc.sysc = 'ENDDAY' no-lock no-error.
if available sysc and sysc.daval <> ? then
dat5 = sysc.daval.

find first cmp no-lock.
v-time = string(time,"HH:MM:SS").
if dat1 <> ? then do:
    if dat5 = ?    then dat5 = today.   /* 12/11/2008 id00363 - поменял g-today на today в заголовке */ 
    display cmp.name format "x(79)" dat5 format "99/99/9999" v-time skip
     with /*centered*/ row 1 no-box no-label width 110 frame hdr.
end.
else
display cmp.name format "x(90)" v-time skip
     with row 1 no-box no-label frame hdr.

repeat: /* looping for ms-dos */
main: repeat:
  if opsys = "msdos" then do:
    view frame login.
    vpkg = fill(" ", integer((23 - length(vpkg)) / 2)) + vpkg.
    display vpkg skip
            "IMS Business System, Corp."
            with centered row 15 no-box no-label.

    g-ofc = "".
    update g-ofc help "Enter EXIT to exit to operating system."
      with frame login.
    if g-ofc = "exit" then quit.
    find ofc where ofc.ofc = g-ofc no-error.
    if not avail ofc then do:
      bell.
      hide message no-pause.
      {mesg.i 0605}.
      {mesg.i 0603}.
      output to value(v-logdir + "/" + "bank.err") append.
      put today space(1) string(time,"HH:MM:SS") space(1)
          "Progress user id:" g-ofc ": Unauthorized access! "
           skip.
      output close.
      undo main, retry.
    end.

    if ofc.pass <> "" then do:
      getpass: do on error undo, retry:
        display "" @ vpass with frame login.
        set vpass blank with frame login.
        {xas016.i "vpass" "getpass"} /* check digits */
        {xas017.i "vpass" "vencpass"} /* encrypt */
        if vencpass <> ofc.pass then do:
          bell.
          {mesg.i 0234}.
          undo getpass, retry.
        end.
      end. /* getpass */
    end. /* if */
  end. /* msdos */

  else if opsys = "unix" then do:
    g-ofc = userid('bank').
    find ofc where ofc.ofc = g-ofc no-lock no-error.
    if not avail ofc then do:
      bell.
      {mesg.i 0605}.
      {mesg.i 0603}.

/* --------------------------------------------- 13.11.2001, by sasco ------*/
      unix silent askhost > askhost.askhost.
      define stream sin.
      define variable sins as char.
      input stream sin from askhost.askhost.
      import stream sin unformatted sins.
      input stream sin close.
      unix silent rm askhost.askhost.
/* -------------------------------------------------------------------------*/
      output to value(v-logdir + "/" + "bank.err") append.
      put today space(1) string(time,"HH:MM:SS") space(1)
          "Not in Pragma users list! Login: ".
      put unformatted trim(g-ofc) " Host: ".
      put unformatted sins skip.
      output close.
      pause 5.
      quit.
    end.
    if g-lang eq "" and ofc.lang ne "" then g-lang = ofc.lang.
    if ofc.father ne "" then do:
      v-father = ofc.father.
      v-entry = v-father.
      v-stack = v-father.
    end.
  end. /* if unix */

view frame nmenu.
view frame fname.

if g-today ne today then do:
  bell.
  pause 0.
  view frame chck.
end.

if not connected("stat") then do:
    if ofc.expr[5] matches "*S*" then do :
        pause 0.
        def var v-passwd as char format "x(16)" .
        def var v-hostname as char.
        def var v-host as char.
        def var v-sname as char.
        update v-passwd blank
        with frame passwd title " PASSWORD " no-label row 12 centered overlay.
        hide frame passwd.

        find sysc "staths" no-lock no-error.
        if available sysc then v-hostname = sysc.chval. else v-hostname = "".

        find sysc "statsn" no-lock no-error.
        if available sysc then v-sname = sysc.chval. else v-sname = "".

        input through hostname .
        repeat :
            import v-host.
        end.
        if v-hostname eq v-host or v-hostname eq "" then do :
            find sysc "statdb" no-lock no-error.
            if available sysc then
            connect value(sysc.chval) -ld stat -U value(userid("bank"))
            -P value(v-passwd).
        end.
        else do:
            find sysc "statdb" no-lock no-error.
            if available sysc then
            connect value(sysc.chval) -ld stat -U value(userid("bank"))
            -P value(v-passwd) -H value(v-hostname) -S value(v-sname) .
        end.
    end.
end.

/* 11.11.2003 nadejda - проверка на устаревание пароля, если больше 30 дней, то запросить смену пароля */
run chpswmenu.
/******/

menu:
repeat:
  v-max = 0.
  v-pos = 1.
  clear frame nmenu all no-pause.
  view frame fname.
  view frame hdr.
  find nmenu where nmenu.fname eq v-father no-lock no-error.
  find nmdes where nmdes.fname eq v-father
              and  nmdes.lang  eq g-lang no-lock no-error.
  if available nmdes then g-mdes = nmdes.des.
                     else g-mdes = "".
  display v-father @ g-fname g-mdes with frame mainhead.

if frame-line(nmenu) = 0 then down 1 with frame nmenu.
refresh:
repeat:
    if frame-line(nmenu) ge frame-down(nmenu) then leave refresh.
    color disp normal nmenu.ln with frame nmenu.
    pause 0. 
    down with frame nmenu.
end.
    up frame-down(nmenu) - 1 with frame nmenu. 

  for each nmenu where nmenu.father eq v-father no-lock:
    find nmdes where nmdes.lang eq g-lang
                and  nmdes.fname eq nmenu.fname no-lock no-error.
    if nmenu.proc eq "" and nmenu.link eq "" then
      v-sts = ">     " + nmenu.proc.
    else if nmenu.link ne "" then
      v-sts = "^     " + nmenu.proc.
    else
      v-sts = "      " + nmenu.proc.
    
    disp nmenu.ln
         nmdes.des format "x(59)" when available nmdes
         nmenu.fname format "x(16)"
         v-sts
      with frame nmenu.
    down with frame nmenu.
    v-max = nmenu.ln.
  end.
  up v-max with frame nmenu.
  down v-ln - 1 with frame nmenu.
  v-ln = 1.


  choose:
  repeat:

    v-time = string(time,"HH:MM:SS").
    display v-time with frame hdr.

    choose row nmenu.ln no-error with frame nmenu.

    if keyfunction(lastkey) eq "PUT" then do:
      find sysc where sysc.sysc = "MANDIR" no-lock no-error.
      if not avail sysc then message "Нет переменной MANDIR в SYSC для помощи по меню!" view-as alert-box title "".
      else do:
         find nmenu where nmenu.father eq v-father and 
                          nmenu.ln eq integer(frame-value) no-lock no-error.
         if available nmenu then 
         do:
            v-ifname = nmenu.fname.
            unix value(g-browse) value(sysc.chval + "/" + v-ifname).
         end.
         else bell.
      end.
    end.

    else if keyfunction(lastkey) eq "GET" then do:
      find sysc where sysc.sysc = "MANDIR" no-lock no-error.
      if not avail sysc then message "Нет переменной MANDIR в SYSC для помощи по меню!" view-as alert-box title "".
      else do:
         find nmenu where nmenu.father eq v-father
                          and  nmenu.ln eq integer(frame-value) no-lock no-error.
         if available nmenu then 
         do:
            v-ifname = nmenu.fname.
            unix value(g-browse) value(sysc.chval + "/" + v-ifname).
         end.
         else bell.
      end.
    end.

    else if keylabel(lastkey) eq "ctrl-f" or keylabel(lastkey) eq "ctrl-а" /** SASCO поиск по наименованию **/
    then do:
         vtmen = "".
         do on endkey undo, leave:
         update vtmen label "Часть названия" with row 15 centered 
                overlay side-labels frame getmen title "Поиск".
         hide frame getmen.
            
         end.
         hide frame getmen.
         if lastkey = keycode ("PF4") then next menu.
         g-fname =  "".
         if vtmen <> "" then run nmenu_findmenu.
         if g-fname = "" then do:  
            run menudumb. pause 0.
            next menu.
         end.
         leave choose.
         vtmenmode = true.
    end.
    

    else if keyfunction(lastkey) eq "RETURN" or
            keyfunction(lastkey) eq "GO" then do:
      
      find nmenu where nmenu.father eq v-father
                  and nmenu.ln eq integer(frame-value) no-lock no-error.
      if available nmenu then do:
        g-fname = nmenu.fname.
        leave choose.
      end.
      else bell.
    end.

    else if lastkey ge 65 and lastkey le 90 or
            lastkey ge 97 and lastkey le 122 then do:
      v-first = true.
      set g-fname validate(can-find(nmenu where nmenu.fname eq g-fname no-lock) or
                            g-fname eq "QUIT"
                          ,"Wrong Function Name")
        with frame fname
      editing:
        if v-first then do:
          apply lastkey.
          v-first = false.
        end.
        readkey.
        if keyfunction(lastkey) eq "PUT" then do:
          v-ifname = caps(input g-fname).
          unix value(g-editor) value("/usr/pm/info/" + g-lang + "/" + v-ifname).
        end.
        else if keyfunction(lastkey) eq "GET" then do:
          v-ifname = caps(input g-fname).
          unix value(g-browse) value("/usr/pm/info/" + g-lang + "/" + v-ifname).
        end.
        else apply lastkey.
      end.
      if g-fname eq "QUIT" then
      do transaction:
          /* suchkov - 24.05.2004 
          find ofc where ofc.ofc = userid('bank') exclusive-lock.
          ofc.expr[2] = "".
          ofc.expr[2] = " QUIT " + " at  " + string(today) + " "
           + string(time,"HH:MM:SS").
          release ofc.  */
          if connected ("comm") then disconnect 'comm'. 
          quit.
      end.

      leave choose.
    end.

    else bell.

  end. /* choose */

  if keyfunction(lastkey) eq "END-ERROR" then do: /* end key pressed */
    if v-father eq v-entry then bell. /* no more previous menu */
    else do:
      v-stack = substring(v-stack,index(v-stack,",") + 1).
      v-ln = integer(entry(1,v-lnstack)).
      v-lnstack = substring(v-lnstack,index(v-lnstack,",") + 1).
      find nmenu where nmenu.fname eq v-father no-lock no-error.
      v-father = entry(1,v-stack).
    end.
  end. /* end key pressed */

  else do: /* a function has been selected */
    find nmenu where nmenu.fname eq g-fname no-lock.
    find nmdes where nmdes.fname eq nmenu.fname
                and  nmdes.lang  eq g-lang no-lock no-error.
    g-fname = nmenu.fname.
    v-lnproc = false.
    if nmenu.link ne "" then do: /* link ? */
      find b-nmenu where b-nmenu.fname eq nmenu.link no-lock.
      if b-nmenu.proc ne "" then v-lnproc = true.
    end. /* link ? */

    if nmenu.link ne "" and v-lnproc eq false then do: /* linked menu */
      v-father = nmenu.link.
      v-stack = g-fname + "," + v-stack.
      v-lnstack = string(nmenu.ln) + "," +  v-lnstack.
      next menu.
    end. /* linked menu */
    else if nmenu.proc eq "" and v-lnproc eq false then do: /* unlinked menu */
      v-father = nmenu.fname.
      v-stack = g-fname + "," + v-stack.
      v-lnstack = string(nmenu.ln) + "," +  v-lnstack.
      next menu.
    end. /* unlinked menu */
    else do: /* procedure not menu */
      v-tmpln = nmenu.ln.
      if v-lnproc eq true then do: /* linked procedure */
        g-proc = b-nmenu.proc.
        v-func = b-nmenu.fname.
      end. /* linked procedure */
      else do: /* unlinked procedure */
        g-proc = nmenu.proc.
        v-func = nmenu.fname.
      end. /* unlinked procedure */
      if available nmdes then g-mdes = nmdes.des.
      if search(g-proc + ".r") eq ? then do:
        {mesg.i 0872}.
      end. /* compile procedure not exist */
      else do: /* compiled procedure exist */
        find ofc where ofc.ofc eq userid('bank') no-lock no-error.

        /* ПРОВЕРКА ПРАВ ДОСТУПА */
        ofc_stack = ''.
        if not nmenu_check_permis(ofc.ofc, v-func) then do:
          view frame sorry1.
          output to value(v-logdir + "/" + "pm.err") append.
          put today space(1) string(time,"HH:MM:SS") space(1)
                    g-ofc " Unauthorized use for "
                    v-func skip.
          output close.
          pause 3.
        end. /* security violated */
/*
        find sec where sec.ofc eq ofc.ofc
                  and  sec.fname eq v-func no-lock no-error.
        if ofc.ofc ne "ROOT" and not available sec then do:
          bell.
          view frame sorry1.
          output to value(v-logdir + "/" + "pm.err") append.
          put today space(1) string(time,"HH:MM:SS") space(1)
              g-ofc " Unauthorized use for "
              v-func skip.
          output close.
          pause 3.
        end. /* security violated */
*/
        else do: /* security ok */
          g-tty = nmenu.ntty.
          g-lty = truncate(nmenu.ntty / 100 ,0) mod 10.
          hide all.
          f-prc = g-proc.

          run value(g-proc).

          /*
          do transaction :                                                
            find first bat where bat.aaa = f-prc use-index aaa
             exclusive-lock no-error.
            if available bat then do :
              bat.regdt = g-today.
              bat.chkno = bat.chkno + 1.
              if index(trim(bat.who),trim(userid('bank'))) = 0 then
                bat.who = bat.who + "," + trim(userid('bank')).

            end.
            else do :
               create bat.
               bat.bat =  integer(string(day(g-today)) + 
                 string(month(g-today)) + string(time)).
               bat.aaa = trim(f-prc).
               bat.regdt = g-today.
               bat.chkno = 1.
               bat.who = userid('bank').

            end.
            release bat.
          end.
     */

          hide all.
          g-proc = "nmenu".
          g-mdes = "".
          g-tty = 0.
          g-lty = 0.
        end. /* security ok */
      end. /* compiled procedure exist */
      v-ln = v-tmpln.
    end. /* procedure not menu */
  end. /* a function has been selected */
end. /* menu */

end. /* main */
end. /* loopingfor ms-dos */


/* Commented because performance problem;
   This routine should be located after select procedure
define var v-stack as cha.
define var v-ln like nmenu.ln.
define var v-lnstack as cha.
define var v-deep as int.
define var v-find as log.
v-stack = v-entry.
v-ln = 1.
v-deep = 1.
v-find = false.
repeat:
  find nmenu where nmenu.father eq entry(1,v-stack)
              and  nmenu.ln eq v-ln no-error.
  if not available nmenu then do:
    if v-deep eq 1 then leave.
    v-ln = integer(entry(1,v-lnstack)).
    v-stack = substring(v-stack,index(v-stack,",") + 1).
    v-lnstack = substring(v-lnstack,index(v-lnstack,",") + 1).
    v-deep = v-deep - 1.
    put skip(1).
    next.
  end.
  if nmenu.fname eq g-fname then do:
    v-find = true.
    leave.
  end.
  v-ln = v-ln + 1.
  if nmenu.proc eq "" then do:
    if nmenu.link eq "" then v-stack = nmenu.fname + "," + v-stack.
    else v-stack = nmenu.link + "," + v-stack.
    v-lnstack = string(v-ln) + "," +  v-lnstack.
    v-ln = 1.
    v-deep = v-deep + 1.
  end.
end.
if v-find eq false then do:
  bell.
  {mesg.i 0611}.
  next.
end.
*/
