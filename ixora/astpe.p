/* astpe.p
 * MODULE
        OC
 * DESCRIPTION
        Перенос ОС между подразделениями
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
 * BASES
        BANK COMM
 * AUTHOR
        03/09/2010 marinav
 * CHANGES
            21/05/2012 Luiza - если остаточная стоимость равна нулю rmz платеж не создаем
            25/05/2012 Luiza - перекомпиляция
            24/05/2013 Luiza - ТЗ 1842 закрепление ОС за сотрудником
*/

def new shared var s-jh like jh.jh.
def new shared var v-ast like ast.ast format "x(8)".
def new shared var txb-ast like bank.ast.ast format "x(8)".
def new shared var v-arp like bank.arp.arp.
def new shared var v-rnn as char.
def new shared var v-bname as char.
def new shared var v-gl  like ast.gl.
def new shared var v-gl3  like ast.gl.
def new shared var v-gl4  like ast.gl.
def new shared var v-qty like bank.ast.qty format "zzz,zz9".
def new shared var v-fag as char format "x(3)".
def new shared var v-sum as dec format "zzz,zzz,zz9.99".
def new shared var v-cont like ast.cont format "x".
def new shared var v-crline as dec format "zzzzzzz9.99-" init 0.
def new shared var v-ydam5 as dec format "zzzzzzz9.99-" init 0.
def new shared var v-icost like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-nol  like ast.icost format "zzzzzz,zzz,zz9.99".
def new shared var v-atl  like ast.icost format "zzzzzzzz,zz9.99".
def var v-fond like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-sum1 like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-sumd like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-sumr like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-name like ast.name.
def var v-mfc like ast.mfc format "x(30)".
def var v-rem like ast.rem.
def var v-rdt like ast.rdt.
def var v-ref  as decim format "zz9".
def var v-ddt  as date.
def var v-fagn like fagn.naim.
def var v-addr as char format "x(3)".
def var v-attn as char format "x(3)".
def var v-addr2 as char format "x(10)".
def var v-addrn as char format "x(25)" init " ".
def var v-attnn as char format "x(25)" init " ".
def var v-gln as char.
def var v-gl3d like gl.des.
def var v-gl4d like gl.des.
def new shared var v-atrx as char.
def new shared var v-arem as char extent 5 format "x(80)".
def new shared var vop as int.
def new shared var kor-gl like jl.gl.
def new shared var kor-acc like arp.arp.
def new shared var kor-gl1 like jl.gl.
def var v-kdes as char.
def var v-gldes as char.
def var v-kdes1 as char.
def var v-gldes1 as char.
def var v-kdesr as char.
def var v-gldesr as char.
def var v-kdesd as char.
def var v-gldesd as char.
def new shared var vidop as char.
def var otv as log .
def var klud as log init true.
def var kodcrc as char format "x(3)" init " ".

def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var vparam as cha .
def var shcode as cha .
def var arem as char.
def var arem1 as char.
def var arem2 as char.

def var v-str1d as char.
def var v-str1c as char.
def var v-str2 as char.
def var v-bank as char.
def var v-bankname as char.
def var v-rmz  like remtrz.remtrz no-undo.


{global.i}

form
  "ГРУППА     :" v-fag  v-fagn format "x(25)" "СЧЕТ :" v-gl v-gln format "x(17)" skip
  "КАРТОЧКА   :" v-ast format 'x(28)'  " ИНВ. Nr." v-addr2 format "x(20)" skip
  "НАЗВАНИЕ   :" v-name  skip
  "ПРИМЕЧАНИЕ :" v-rem         " Дата регист.:" at 45 v-rdt  skip
  "------------------  Дата  выбытия       " g-today " ------------------" skip
  "КОЛИЧЕСТВО ОС    :" v-qty   "БАЛАНС.СТОИМ.  :" at 38 v-icost skip
  "ОСТАТОЧНАЯ СТОИМ.:" v-atl   "ИЗНОС          :" at 38 v-nol  skip
                               "ФОНД ПЕРЕОЦЕНКИ:" at 38 v-fond  skip
  "------------------------------------------------------------------------" skip
  "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
  "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip(1)
  "ФИЛИАЛ       :" v-bank " " v-bankname format "x(30)" skip
  with frame ast row 3 overlay centered no-label  title "  " + v-arem[1] + " ОС ".

def var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).


on help of v-bank in frame ast do:
{itemlist.i
       &file = "txb"
       &where = "txb.bank begins 'txb'"
       &form = "txb.bank txb.info form ""x(30)""  "
       &frame = "row 5 centered scroll 1 18 down overlay "
       &flddisp = "txb.bank txb.info"
       &chkey = "bank"
       &chtype = "string"
       &index  = "bank"
       &funadd = "if frame-value = '' then do:
		    message 'Банк не выбран'.
		    pause 1.
		    next.
		  end." }
  v-bank = frame-value.
  displ v-bank with frame ast.
end.


klud=true.
ma:
repeat on endkey undo,return:
    hide all.

    find asttr where asttr.asttr = "o" no-lock no-error.
    if avail asttr then v-arem[1]=asttr.atdes.

    update v-ast validate(v-ast ne ""," ВВЕДИТЕ НОМЕР КАРТОЧКИ   " ) with frame ast.
    find ast where ast.ast=v-ast no-lock no-error.
    if not avail ast then do:
        message "КАРТОЧКИ НЕТ ". pause 5. next.
    end.
    if ast.dam[1] - ast.cam[1] eq 0 then do:
        message "ОСТАТОК  0 ". pause 5. return.
    end.

    if ast.own <> "" then do: message "ОС не откреплено от сотрудника ". pause 5. return. end.

    v-gl=ast.gl.
    find gl where gl.gl=v-gl no-lock.
    v-gln=gl.des.
    find first trxlevgl where trxlevgl.gl=ast.gl and trxlevgl.lev=3 no-lock no-error.
    if available trxlevgl then v-gl3 = trxlevgl.glr. else v-gl3=?.
    find gl where gl.gl eq v-gl3 no-lock no-error.
    if available gl then v-gl3d =gl.des. else v-gl3d="".

    find first trxlevgl where trxlevgl.gl=ast.gl and trxlevgl.lev=4 no-lock no-error.
    if available trxlevgl then v-gl4 = trxlevgl.glr. else v-gl4=?.
    find gl where gl.gl eq v-gl4 no-lock no-error.
    if available gl then v-gl4d =gl.des. else v-gl4d="".

    find first crc where crc.crc=ast.crc no-lock.
    if avail crc then kodcrc=crc.code.

    v-fag=ast.fag.
    find fagn where fagn.fag=v-fag no-lock.
    v-fagn=fagn.naim.
    v-rdt=ast.rdt.
    v-ddt=ast.ddt[1].
    v-qty=ast.qty.
    v-fond = ast.cam[4] - ast.dam[4].
    v-icost= ast.dam[1] - ast.cam[1].
    v-nol  = ast.cam[3] - ast.dam[3].
    v-atl= v-icost - v-nol.
    v-addr=ast.addr[1].
    v-addr2=ast.addr[2].

    find astotv where astotv.kotv=v-addr and astotv.priz="A" no-lock no-error.
    if avail astotv then v-addrn=astotv.otvp.

    v-attn=ast.attn.
    find codfr where codfr.codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
    if avail codfr then  v-attnn = codfr.name[1].

    v-cont=ast.cont.
    v-ref=integer(ast.ref).
    v-crline=ast.crline.
    v-ydam5=ast.ydam[5].
    v-name=ast.name. v-mfc=ast.mfc. v-rem=ast.mfc.

    displ  v-fag v-fagn v-ast v-addr2 v-gl v-gln v-qty  v-rdt v-name v-mfc v-rem  v-addr v-addrn v-attn v-attnn v-atl v-icost v-nol v-fond g-today with frame ast.

    do on error undo,retry on endkey undo,next ma:
         update v-qty validate(v-qty >0 and v-qty <= ast.qty , " кол-во " + string(ast.qty)) with frame ast.

          v-icost = round(v-icost / ast.qty * v-qty,2).
          v-nol = round(v-nol / ast.qty * v-qty,2).
          v-fond = round(v-fond / ast.qty * v-qty,2).
          v-atl=v-icost - v-nol.
          disp v-atl v-nol v-icost v-fond with frame ast. pause 0.

          update v-bank with frame ast.
          if v-bank = s-ourbank then do:
             message "Клиент вашего филиала! " view-as alert-box.
             return.
          end.

          find first txb where txb.bank = v-bank no-lock no-error.
          if not avail txb then return.
          v-bankname = txb.info.
          displ v-bankname with frame ast.

          v-arem[1]=v-arem[1] + " филиал в " + v-bankname + " " +  trim( v-name) + ".".
          v-arem[2]="Баланс.ст. " + trim(string(v-icost,"zzzzzzzz9.99-")) + " " + kodcrc +  " износ " + trim(string(v-nol,"zzzzzzzz9.99-")).
          otv=true.
          message "  ПРОДОЛЖИТЬ ?  " UPDATE otv format "да/нет".
          if not otv then next ma.
    end.


    m1:
    repeat on error undo,retry on endkey undo,next ma:

      v-str1d=string(v-gl3,"zzzzz9") + " " + substring(v-gl3d + "                                      ",1,29) + " " + substring(v-ast,1,10) + "              " + string(v-nol,"zzz,zzz,zzz,zz9.99") + "  DR".

      v-str1c=string(v-gl,"zzzzz9") + " " +  substring(v-gln + "                                      ",1,29) + " " + substring(v-ast,1,10) + "              " + string(v-nol,"zzz,zzz,zzz,zz9.99") + "  CR".

      v-str2=string(v-gl,"zzzzz9") + " " + substring(v-gln + "                                      ",1,29) + " " + substring(v-ast,1,10) + "              " + string(v-atl,"zzz,zzz,zzz,zz9.99") + "  CR".

            form
            "     Счет                              Субсчет                      Сумма " kodcrc skip
            "---------------------------------------------------------------------------------" skip
            ""   v-str1d  format "x(88)"  skip
            ""   v-str1c  format "x(88)"  skip
            ""   v-str2  format "x(88)"  skip
            ""  kor-gl  v-gldes format "x(29)"   kor-acc      v-atl format "zzz,zzz,zzz,zz9.99"  " DR" skip
             v-kdes  at 12  format "x(30)"            skip   skip(4)
            "ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
             with frame kor4 overlay  no-labels row 8 width 100.

             find first sysc where sysc.sysc = 'tros' no-lock no-error.
             if not avail sysc then do: message "Нет настроек транзитного счета tros". return. end.
             kor-acc = entry(1,sysc.chval).
             find arp where arp.arp eq kor-acc no-lock no-error.
             if not available arp then do: bell. {mesg.i 2203}. undo,retry. end.
             if arp.crc <> ast.crc then do: bell. {mesg.i 9813}. undo,next. end.
             kor-gl=arp.gl.
             v-kdes=arp.des.
             find gl where gl.gl=kor-gl no-lock no-error.
             if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
             v-gldes=gl.des.
             displ v-str1d v-str1c v-str2  v-atl  v-arem[1] v-arem[2] v-arem[3] kor-gl kor-acc v-gldes  kodcrc v-kdes with frame kor4.

             update v-arem[1] v-arem[2] v-arem[3] with frame kor4.

     klud=false.
     leave.
   end. /*repeat*/

   if klud then return.

   otv=true.
   message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
   if not otv then next ma.

leave.
end. /*ma*/

 klud=true.
 do transaction:

   arem=trim(trim(v-arem[1]) + " " + trim(v-arem[2]) + " " + trim(v-arem[3])).
   arem1="". arem2="".
   if v-nol > 0 then  arem1=arem. else arem2=arem.

   shcode="AST0011".
   vparam=string(v-nol)         + vdel +
          v-ast                 + vdel +
          arem1                 + vdel +
          string(v-atl)         + vdel +
          kor-acc               + vdel +
          arem2.

   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes, input-output s-jh).
   if rcode > 0 or s-jh = 0  then
   do:
         Message " Error: " + string(rcode) + ":" +  rdes .
         pause .
         undo,return .
   end.
   else do:
           find ast where ast.ast = v-ast exclusive-lock.
                   ast.icost = ast.dam[1] - ast.cam[1].
                   ast.qty = ast.qty - v-qty.
                   ast.crline = ast.crline - v-crline.
                   ast.ydam[5] = ast.ydam[5] - v-ydam5.
                   ast.ofc = g-ofc.
                   ast.updt = g-today.
      create astjln.
      astjln.ajh = s-jh.
      astjln.aln = ast.crc.
      astjln.awho = g-ofc.
      astjln.ajdt = g-today.
      astjln.arem[1] = substring(v-arem[1],1,55).
      astjln.arem[2] = substring(v-arem[2],1,55).
      astjln.arem[3] = substring(v-arem[3],1,55).
      astjln.arem[4] = substring(v-arem[4],1,55).
      astjln.d[1 ]= 0.
      astjln.c[1] = v-icost.
      astjln.d[3] = v-nol.
      astjln.c[3] = 0.
      astjln.d[4] = v-fond.
      astjln.c[4] = 0.
      astjln.adc = "C".
      astjln.agl = v-gl.
      astjln.aqty= v-qty.
      astjln.aast = v-ast.
      astjln.afag = v-fag.
      astjln.atrx = 'o'.
      astjln.ak = v-cont.
      astjln.crline = v-crline.
      astjln.prdec[1] = v-ydam5.
      astjln.icost = v-icost.
      astjln.korgl = kor-gl.
      astjln.koracc = kor-acc.
      astjln.vop = vop.
      find first astatl where astatl.agl = ast.gl and astatl.ast = ast.ast and  astatl.dt = g-today exclusive-lock no-error.
             if not available astatl then create astatl.
             astatl.ast = ast.ast.
             astatl.agl = ast.gl.
             astatl.fag = ast.fag.
             astatl.dt = g-today.
             astatl.icost = ast.dam[1] - ast.cam[1] .
             astatl.nol =  ast.cam[3] - ast.dam[3].
             astatl.fatl[4] = ast.cam[4] - ast.dam[4].
             astatl.atl = astatl.icost - astatl.nol.
             astatl.qty = ast.qty.

       run x-jlvouR.
       pause 0 .
       klud=false.
   end.
 end. /* tranz*/

release ast.
release astatl.
release astjln.

if rcode = 0 and not klud then do:
        find first cmp no-lock no-error.
        find first txb where txb.bank = v-bank no-lock no-error.
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

        run astpe1.
        v-rmz = "".
        if v-atl <> 0 then do:
            run rmzcretxb (
                    1    ,
                    v-atl,
                    v-arp,
                    v-rnn,
                    v-bname     ,
                    s-ourbank  ,
                    kor-acc    ,
                    bank.cmp.name   ,
                    bank.cmp.addr[2]   ,
                    0  ,
                    no ,
                    '890'  ,
                    '14'  ,
                    '14'  ,
                    'Передача ОС ' ,
                    '2T'     ,
                    1     ,
                    5     ,
                    g-today,
                    'arp'    ).

                   v-rmz = return-value.
                   if connected ("txb") then disconnect "txb".
        end.
end.

do trans:
       if v-rmz ne "" or v-atl = 0 then  do:
            message " На филиале " + v-bname + " сделан платеж " + v-rmz  view-as alert-box.

            create clsdp.
                 clsdp.aaa =  txb-ast.
                 clsdp.txb = v-bank.
                 clsdp.sts = '10'.
                 clsdp.rem = 'ast0012'.
                 clsdp.prm = string(v-nol)  + vdel + v-arp + vdel + txb-ast + vdel + arem1 + vdel + string(v-icost)  + vdel + arem2.
       end.
       else do:
            message " Платеж  по переводу средств не сделан!!!! "  view-as alert-box.
       end.
end.
