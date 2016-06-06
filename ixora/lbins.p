/* lbins.p
 * MODULE
        Платежная система
 * DESCRIPTION
        сверка СМЕП по финальной выписке.
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * BASES
        BANK
 * AUTHOR
        19.08.2013 galina ТЗ1871
 * CHANGES
*/


{global.i}
 def new shared var v-lbin as cha .
 def new shared var v-lbina as cha .
 def new shared var v-lbeks as cha .
 def new shared var v-lbhst as cha .
 def var v-lbtyp as char no-undo.
 def var exitcod as cha initial "" no-undo.
 def var lbnum as int no-undo.
 def new shared var v-ok as log .
 def new shared var card-gl as char.
 def var v-excheq as decimal init 3000000 no-undo.  /* входящие платежи Казначейства Минфина с суммой больше этой попадают на доп.контроль */
 def var v-nostro as char init "400161370" no-undo.
 def var v-arplbi as char no-undo.
 def var v-cls as date no-undo.
 def var num as cha extent 20 no-undo.
 def var t-str as cha no-undo.
 def stream f-file .
 def var yn as log no-undo.
 DEF NEW SHARED STREAM PROT .
 def new shared var n-pap as int .
 def new shared var n-sum like remtrz.amt .
 def new shared  var n-papv as int init 0 .    /*  for qqq  */
 def new shared var ir as int .
 def new shared var irt as int .
 def new shared var totr-sum like remtrz.amt .
 def new shared var totv-sum like remtrz.amt.
 def new shared  var n-sumv like remtrz.amt init 0 .   /*  or qqq  */
 def new shared var ivt as int.
 def new shared var iv as int.
 def var v-strALL as cha no-undo.
 def var rmz_rnn as char no-undo.
 def var i as int no-undo.
 def var choice as log no-undo.

 def new shared  temp-table qrr
     field remtrz like remtrz.remtrz
     field pid like que.pid
     field amt like remtrz.amt
     field bank like remtrz.rbank
     field sqn like remtrz.t_sqn
     field fname as char
     field ff as log init no
     index sqn is primary sqn
     index fname fname
     index ff ff.


def temp-table t-qarc no-undo
    field fname as char.

def new shared temp-table t-qin
    field fname as char.

{lgps.i new}


find sysc where sysc.sysc = "LBIN" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " ERROR !!! There isn't record LBIN in sysc file !! ".
   message v-text .
   run lgps.
   return .
end.
v-lbin = sysc.chval.

find sysc where sysc.sysc = "LBINA" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " ERROR !!! There isn't record LBINA in sysc file !! ".
   message v-text .
   run lgps.
   return .
end.
v-lbina = sysc.chval.

if v-lbin = v-lbina then do :
   v-text = " ERROR !!! Records LBIN and LBINA are equal !! ".
   message v-text .
   run lgps.
   return .
end .

find sysc where sysc.sysc = "LBHST" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " ERROR !!! There isn't record LBHST in sysc file !! ".
   message v-text .
   run lgps.
   return .
end.
v-lbhst = sysc.chval.

find sysc where sysc.sysc = "LBEKS" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   v-text = " ERROR !!! There isn't record LBEKS in sysc file !! ".
   message v-text .
   run lgps.
   return .
end.
v-lbeks = replace(sysc.chval, "/", "\\\\") .

v-cls = g-today .

m_pid = "LBI".
u_pid = "lbin" .

num = "" .

/*for each t-qin: delete t-qin. end.*/
empty temp-table t-qin.
input through value("/bin/ls -lt " + v-lbin + "*.*" ) .

repeat :
    import num .
    if search(num[9]) eq num[9]  then do:
         input stream f-file from value(num[9]) .
         import stream f-file t-str .
         if t-str begins "\{1:" then repeat:
             import stream f-file t-str .
             if t-str begins "\{2:" then do:
                  if substr(t-str,4,4) = "O970" and substr(t-str,18,4) = 'SMEP' then do:
                      create t-qin.
                      t-qin.fname = "970 " + substr(num[9],length(v-lbin) + 1 ) + " " + num[6] + num[7] + " " + num[8] +  ",".
                      find first lbinf where lbinf.rdt = g-today and lbinf.name = num[9]  no-lock no-error.

                      if not avail lbinf then do:
                         create lbinf .
                         assign lbinf.rdt = g-today
                                lbinf.name = num[9]
                                lbinf.gc = 'smep'
                                lbinf.who = g-ofc
                                lbinf.whn = today
                                lbinf.tim = time.
                      end.
                      leave .
                  end.
             end.
         end.
       input stream f-file close .

    end.
end.
input close .

Message " Сверка ... "  .

v-ok = false.

do transaction:
   run lb-check ('smep').   /* сверка */
   MESSAGE "" . pause 0 .

   v-text = " Сверка SMEP проведена : " +
            "Total doc stmt inward "  + string(n-pap)  + ", summ " + string(n-sum) +
            " Total doc LBI "         + string(irt)    + ", summ " + string(totr-sum) +
            "Total doc stmt outward " + string(n-papv) + ", summ " + string(n-sumv) +
            " Total doc STW "         + string(ivt)    + ", summ " + string(totv-sum) +
            " Stmt Inward summa  - Total summa LBI = " +   string(n-sum - totr-sum) .
   run lgps .

   unix value( 'joe -rdonly ' + v-lbin + 'recons.err'  ).
   MESSAGE "Хотите продолжить?" VIEW-AS ALERT-BOX MESSAGE BUTTONS Yes-No TITLE "" UPDATE choice.
   if choice = no then return.

end.

do transaction :

   for each que where  que.pid = "STW" exclusive-lock,
       each remtrz where remtrz.remtrz = que.remtrz and remtrz.cover = 6 and remtrz.fcrc = 1 exclusive-lock ,
       each qrr where qrr.sqn = remtrz.t_sqn exclusive-lock .

       if qrr.ff then que.rcod = "0" .
       else do:
           que.rcod = "2" . /*  have not been reconsilated  */
           v-text = remtrz.remtrz + " не прошел сверку " .
           run lgps .
       end.
       que.con = "F" .
       v-text = que.remtrz + " was checked and send by route rcod= " + que.rcod.
       run lgps .
   end.  /* for each que */
end . /* do transaction */


/*Message " Сделать архив документов текущего дня ? " update yn .
if yn then  do:

    unix value( "ssh " + v-lbhst + " C:\\\\backup\\\\BM.bat"  ).
    pause 0.
    v-strALL = "lb" + substr(string(year(g-today)),3)
                    + string(month(g-today),"99")
                    + string(day(g-today),"99") + "ALL.tar" .

    input through value("lbtoarc "  + v-lbin + " " + v-strALL +  " " + v-lbina + " > qq; echo $?") .
    pause 0.

    repeat :
       import unformatted exitcod .
    end .
    if exitcod <> "0" then do :
        message "Ошибка при создании архива платежей !"    "Код возврата = " exitcod  .
        pause .
        yn = false .
        Message "Продолжить ? " update yn .
        if not yn then undo,leave .
    end .
    pause 0.
end.*/
