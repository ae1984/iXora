/* astie.p
 * MODULE
        Основный средства
 * DESCRIPTION
        Ввод и регистрация карточек О.С.
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
        23/04/03 sasco история перемещений
        09/03/04 sasco добавил функцию getprec() для установки ast.ref (% износа)
        10.02.10 marinav - расширение поля счета до 20 знаков
        25/06/2013 Luiza - ТЗ 1894
        06/09/2013 Luiza - ТЗ 2077

*/

/*  1  3 8 */
/*  */

def new shared var s-jh like jh.jh.
def new shared var s-aah as int.
def new shared var s-force as log init false.
def new shared var s-consol like jh.consol.
def new shared var s-line as int.
def buffer xaaa for aaa.
def var bila like aaa.cbal label "БАЛАНС ".

def input parameter vo as char.

def new shared var v-ast like ast.ast.
def var ast like ast.ast.
def new shared var v-gl  like ast.gl.
def var v-name like ast.name.
def var v-mfc like ast.mfc format "x(30)".
def var v-rem like ast.rem.
~def new shared var v-qty like ast.qty format "zz9" init 1.
def var v-mqty like ast.qty format "zz9" .
def var v-mmqty like ast.qty format "zz9" .
def new shared var v-fag as char format "x(3)".
def new shared var v-icost like ast.icost format "zzz,zzz,zzz,zz9.99".
def new shared var v-sum as dec format "zzz,zzz,zzz,zz9.99".
def new shared var v-cont like ast.cont format "x".
def new shared var v-crline as dec format "zzzzzzzzzzz9.99-" init 0.
def new shared var v-ydam5 as dec format  "zzzzzzzzzzz9.99-" init 0.
def var v-sum1 as dec format "zz,zzz,zz9.99".
def var v-ser like ast.ser.
def var v-noy like ast.noy init 0.
def var v-rdt like ast.rdt.
def var v-salv like ast.salv format "zzz,zzz,zzz,zz9.99" init 0.
def var v-ref  as decim format "zz9" init 0.
def var v-ddt  as date.
def var v-fagn like fagn.naim.
def var v-addr as char format "x(3)".
def var v-attn as char format "x(3)".
def var v-addrn as char format "x(25)" init " ".
def var v-attnn as char format "x(25)" init " ".
def var v-addr2 as char format "x(10)".
def var v-kdes as char.
def var v-gldes as char.
def var v-kdes1 as char.
def var v-gldes1 as char.
def var v-gln as char.
def new shared var v-atrx as char.
def new shared var v-arem as char extent 5 format "x(55)".
def new shared var rem as char extent 5 format "x(55)".
def new shared var vop as int.
def new shared var kor-gl like jl.gl.
def new shared var kor-acc like arp.arp.
def new shared var kor-gl1 like jl.gl.
def new shared var kor-acc1 like arp.arp.
def new shared var vidop as char.
def var otv as log.
def var klud as log init true.

def new shared var sumd1 as dec format "zz,zzz,zz9.99".
def new shared var sumc1 as dec format "zz,zzz,zz9.99".
def new shared var sumd3 as dec format "zz,zzz,zz9.99".
def new shared var sumc3 as dec format "zz,zzz,zz9.99".
def var v-str3 as char format "x(88)".
def var v-str4 as char format "x(88)".
define variable v-gl3 like trxlevgl.glr.
define variable v-gl3d like gl.des.
define variable v-gl4  like trxlevgl.glr.
define variable v-gl4d like gl.des.
define var kodcrc like crc.code.
define var crc like crc.crc.
def var v-ydam4 as dec.
def var v-ycam4 as dec.
def var v-fond as dec.
def var v-fond1 as dec.

def var vdel as cha initial "^" .
def var rdes   as cha .
def var rcode   as int .
def var vparam as cha .
def var shcode as cha .
def var arem as char.

def temp-table sh-jh
field jh as int.

FUNCTION getprec returns DECIMAL.

  find first taxcat where taxcat.type = INTEGER(fagn.cont)
                      and taxcat.cat = INTEGER(fagn.ref)
                      and taxcat.active = true
                          no-lock no-error.
  if avail taxcat then return (taxcat.pc).
                  else return(?).

END FUNCTION.

{global.i}
/*.
form
"     Счет                              Субсчет   Дебет           Кредит  Вал.1" skip
"-----------------------------------------------------------------------------" skip
"001"   v-gl  v-gln format "x(27)"       v-ast           skip
       v-name at 12 format "x(30)"     v-sum  to 55     "0.00"  to 72 skip
"002"   kor-gl  v-gldes format "x(27)"  kor-acc  skip
v-kdes  at 12  format "x(30)"          "0.00" to 55     v-sum1 to 72 skip
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor overlay centered no-labels row 11.
.*/

form
"     Счет                              Субсчет                          Сумма " kodcrc skip
"---------------------------------------------------------------------------------------------" skip
"   "   v-gl  v-gln format "x(27)"       v-ast     v-icost to 85 " DR" skip
"   "  v-str3 format "x(72)"  skip
"   "   kor-gl  v-gldes format "x(27)"  kor-acc      v-sum to 85 " CR" skip
 v-kdes  at 12  format "x(30)"            skip
skip(3)
" ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor overlay centered no-labels row 8 width 100.

form
"   "  v-str4 format "x(74)"  skip
"   "  kor-gl1  v-gldes1 format "x(27)"  kor-acc1      v-fond to 85 " DR" skip
       v-kdes1  at 12  format "x(30)"            skip
 with frame kor4 overlay centered no-labels row 15 width 100 no-box.

form
" ОПИСАНИЕ:"  v-arem[1] at 11  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor5 overlay no-labels row 18 column 2 no-box.


form
  "ГРУППА     :" v-fag  v-fagn format "x(25)" "СЧЕТ :" v-gl v-gln format "x(17)" skip
  "КАРТОЧКА   :" v-ast format 'x(28)' " ИНВ. Nr." v-addr2 format "x(20)" skip
  "НАЗВАНИЕ   :" v-name  skip
  "ПАСПОРТ.ДАН:" v-mfc  skip
  "ПРИМЕЧАНИЕ :" v-rem skip
  "-----------------------------------  Дата регистрации   " v-rdt " ------" skip
  "КОЛИЧЕСТВО ОС    :" v-qty
  "ПЕРВОНАЧ.СТОИМ.  :" at 24 v-icost skip
  "ИЗНОС            :" at 24 v-salv  skip
  "СТОИМОСТЬ ОПРИХОД:" at 24 v-sum skip
  "--------------- Данные для расчета налога  -----------------------------" SKIP
  "   НАЛОГ.КАТЕГОРИЯ  :" v-cont "  СТАВКА ИЗНОСА :" v-ref  "%" skip(1)
 /* "ОСТАТ.СТ.ДЛЯ НАЛ НА" v-ddt  v-crline "тек.года изм." v-ydam5 skip */

  "------------------------------------------------------------------------" skip
  "СРОК ИЗНОСА (кол-во лет ):" v-noy  "  КОД ГР.ИЗНОСА :" v-ser format "x(5)"
                                                                     skip(1)
  "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
  "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip
 with frame ast row 1 overlay centered no-label
                 title "  " + v-arem[1] + " ОС ".

form "Карточ.для примера:" ast format "x(8)"
    with frame a1 row 3 overlay centered no-label.


form
"Сумма переоценки основной стоимости :" v-ydam4 format "zzzzzz,zzz,zz9.99-" skip
"Сумма переоценки износа             :" v-ycam4 format "zzzzzz,zzz,zz9.99-" skip
"         ИЗМЕНЕНИЕ Фонда переоценки :" v-fond format "zzzzzz,zzz,zz9.99-" skip
  with frame pereo row 14 overlay centered no-labels no-hide
    title "  КОРРЕКТИРОВКА ФОНДА ПЕРЕОЦЕНКИ ".


hide all.
do transaction :
 if vo="1" then      v-atrx="1".
 else if vo="3" then v-atrx="3".
 else if vo="8" then v-atrx="81".

 vidop ="D".
 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.



 update v-fag validate(can-find(fagn where fagn.fag=v-fag),
                      " ГРУППЫ НЕТ В СПИСКЕ (F2-ПОМОЩЬ)")
    with frame ast.

 find fagn where fagn.fag=v-fag exclusive-lock no-error.
 v-ast=v-fag + string(fagn.pednr, "99999").
 fagn.pednr= fagn.pednr + 1.
      find ast where ast.ast=v-ast no-lock no-error.
       if avail ast then do: pause 1. release fagn. next. end.
 v-gl    =fagn.gl. v-fagn=fagn.naim.
 find gl where gl.gl=v-gl no-lock.
 v-gln   = gl.des.
 v-ser   = fagn.ser.
 v-cont  = fagn.cont.
 v-noy   = fagn.noy.
 v-ref   = getprec().
 v-qty   = 1.
 v-ddt   = date(1,1,year(g-today)).
if vo="1" or vo="8" then v-rdt =g-today. /* ? red ? ldd ? */
                    else v-rdt=?.
 v-crline=0.
 v-addr2 =v-ast.

 update ast with frame a1.
 if ast ne "" then do: find ast where ast.ast=ast no-lock no-error.
  v-addr=ast.addr[1]. v-name=ast.name. v-mfc=ast.mfc. v-rem=ast.rem.
  v-rdt=ast.rdt. v-attn=ast.attn. v-qty=ast.qty.
  /*.v-icost=ast.icost..*/
  v-icost=ast.dam[1] - ast.cam[1].
  v-noy=ast.noy.
  v-cont = ast.cont.
  v-ref = integer(ast.ref).
 /* if ast.cont="" then do: v-cont="". v-ref=0. end.*/
  find last astjln where astjln.aast=ast and astjln.atrx=v-atrx
   use-index astdt no-lock no-error.
  if avail astjln then do: rem[1]=astjln.arem[1]. rem[2]=astjln.arem[2].
                           rem[3]=astjln.arem[3]. rem[4]=astjln.arem[4].
  end.
 end.


 displ  v-fagn v-ast v-addr v-gl v-gln v-qty v-ser v-cont v-ref v-rdt
       /* v-ddt  v-crline v-attn */ v-icost v-salv  v-noy with frame ast.

  find first trxlevgl where trxlevgl.gl=v-gl and trxlevgl.lev=3 no-lock no-error.
  if available trxlevgl then v-gl3 = trxlevgl.glr.
  find gl where gl.gl eq v-gl3 no-lock no-error.
  if available gl then v-gl3d =gl.des.
  find first trxlevgl where trxlevgl.gl eq v-gl and trxlevgl.lev = 4 no-lock no-error.
  if available trxlevgl then v-gl4 = trxlevgl.glr.
  find gl where gl.gl eq v-gl4 no-lock no-error.
  if available gl then v-gl4d = gl.des.

  crc=1.
  find first crc where crc.crc=1 no-lock.
  kodcrc=crc.code.
 release fagn.
end. /*trans*/


v-salv=0.
klud=true.
ma:
repeat on endkey undo,leave  on error undo,retry :

 update v-addr2 v-name v-mfc v-rem  v-rdt validate(v-rdt<=g-today,"")
        v-qty validate(v-qty >0 ," ")
        v-icost validate(v-icost>0,"")
        with frame ast.
 v-mqty = v-qty.
 v-mmqty = v-qty.
 v-qty = 1.

 if vo="3" then do: update v-salv validate(v-salv>=0 and v-salv<=v-icost,"")
                     with frame ast.
                    update v-sum validate(v-sum = v-icost - v-salv,
                       string(v-icost - v-salv))
                     with frame ast.
                end.
 v-sum = v-icost - v-salv. v-sum1=v-sum.
 displ v-sum with frame ast.

 find fagn where fagn.fag=v-fag no-lock no-error.


 update v-cont
       /*.validate(v-cont="" or v-cont=fagn.cont, fagn.cont + " или пусто ").*/

            with frame ast.
/**
  find first fagn where fagn.cont=v-cont no-lock no-error.
  if avail fagn then  v-ref=integer(fagn.ref).
                else  if v-cont<>"" then undo,retry.

 if v-cont="" then v-ref=0.**/
  update v-ref with frame ast.

/***
 if vo="1" or vo="8" then v-ydam5=v-sum.
                      else v-ydam5=0.
  displ v-ydam5 with frame ast.

 if vo="3" then update v-crline validate(v-crline<=v-icost,"")
                       v-ydam5  with frame ast.
***/

  update  v-noy validate(v-noy>=0,"") v-ser with frame ast.


 find codfr where codfr.codfr="brnchs" no-lock no-error.
 if avail codfr then run sub-codv(v-ast,"ast","brnchs",codfr.code).
 else if ambiguous codfr then run subcod(v-ast,"AST").
 else do: message " нет кодификатора : brnchs ". pause. return. end.

  update  v-addr validate(can-find(astotv where astotv.kotv=v-addr and astotv.priz="A"),
                           "Кода " + v-addr + " НЕТ В СЛОВАРЕ")
         with frame ast.
 find astotv where astotv.kotv=v-addr and astotv.priz="A" no-lock no-error.
 if avail astotv then v-addrn=astotv.otvp.
  displ v-addrn with frame ast.

  update  v-attn validate(can-find(codfr where codfr.codfr = "sproftcn" and
                       codfr.code = v-attn and codfr.code matches "..."),
                       "Кода " + v-attn + " НЕТ В СЛОВАРЕ")
       with frame ast.
 find codfr where codfr.codfr = "sproftcn" and codfr.code = v-attn no-lock no-error.
 if avail codfr then  v-attnn = codfr.name[1].
  displ v-attnn with frame ast. pause 0.


 if vo="3" then repeat:
         update v-ydam4 v-ycam4 with frame pereo.
          v-fond=v-ydam4 - v-ycam4.
         update v-fond with frame pereo.

         if v-ydam4 ne 0 and v-ycam4 ne 0 and v-fond ne (v-ydam4 - v-ycam4)
         then message " проверьте суммы".
         else
         if v-fond < 0 then message " фонд переоценки < 0 ".
         else do:
          if v-ydam4 eq 0 and v-ycam4 eq 0 then v-ydam4=v-fond.
          displ v-ycam4 with frame pereo. leave.
         end.
 end.
  pause 1.



 if rem[1] ne "" then do: v-arem[1]=rem[1]. v-arem[2]=rem[2]. v-arem[3]=rem[3].
                          kor-gl=astjln.korgl. kor-acc=astjln.koracc.
                          vop=astjln.vop.
 end.
 else  do:
   find asttr where asttr.asttr=v-atrx no-lock no-error.
   if avail asttr then v-arem[1]=asttr.atdes + " " + v-name.
 end.
/*
end.
*/

m1:
repeat on error undo,retry on endkey undo,next ma:
if vo="8" then vop=1.

vop=1.

if v-salv ne 0 then
     v-str3=string(v-gl3,"zzzzz9") + " " + substring(v-gl3d + "          ",1,28)
            + substring(v-ast,1,10) + "       " +
            string(v-salv,"zzz,zzz,zzz,zz9.99") + "  CR".
else v-str3="".

v-str4="".

displ v-gl v-gln v-ast v-icost v-sum kodcrc
      v-arem[1] v-arem[2] v-arem[3] kor-gl kor-acc
      v-str3  with frame kor.


/*
 message "КРЕДИТ : 1 - ARP "
          update vop auto-return format "9".
*/

vop=1.

/*
 message "КРЕДИТ : 1 - ARP  2 - КАССА 3 - СЧЕТ КЛИЕНТА  4 - СЧЕТ ГЛ.КН." /*4 - DFB"*/
          update vop auto-return format "9".
*/
 if vop <=0 or vop >4 then undo,next m1.

/* IF vo="8" and vop<>1 then do: message "ВЫБЕРИТЕ 1 -ARP ". undo,next m1. end.
*/

{ast-jlk.i}


if v-fond ne 0 then do:

     v-fond1=v-fond.
     v-str4=string(v-gl4,"zzzzz9") + " " +
            substring(v-gl4d + "                                    ",1,28)
            + substring(v-ast,1,10) + "       " +
            string(v-fond,"zzz,zzz,zzz,zz9.99") + "  CR".
  pause 0.
  displ  v-str4 v-fond with frame kor4.

/*
 message "ДЕБЕТ : 1 - ARP "
          update vop auto-return format "9".
*/
   message " Введите номер ARP".
   update kor-acc1 with frame kor4.
   find arp where arp.arp eq kor-acc1 no-lock no-error.
   if not available arp then do: bell. {mesg.i 2203}. undo,retry. end.
   if arp.crc <> 1 then do: bell. {mesg.i 9813}. undo,next. end.
   kor-gl1=arp.gl.
   v-kdes1=arp.des.
   displ kor-gl1 v-kdes1 with frame kor4.
   find gl where gl.gl=kor-gl1 no-lock no-error.
   if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
   v-gldes1=gl.des. displ v-gldes1 with frame kor4.

end.
else kor-acc1=kor-acc.


 /*. displ v-sum1 with frame kor. .*/
  pause 0.
  update v-arem[1] v-arem[2] v-arem[3] with frame kor5.

/* n */
 otv=true.
 message "  ОПЕРАЦИЮ ВЫПОЛНИТЬ ?  " UPDATE otv format "да/нет".
 if otv then do transaction:
    do while v-mqty > 0 :
        if v-mqty < v-mmqty then do:
            message "осталось оприходовать " string(v-mqty) " шт" .  /*view-as alert-box.*/
            pause 1.
             find fagn where fagn.fag=v-fag exclusive-lock no-error.
             v-ast = v-fag + string(fagn.pednr, "99999").
             v-addr2 = v-ast.
             fagn.pednr= fagn.pednr + 1.
             find ast where ast.ast=v-ast no-lock no-error.
             if avail ast then do: pause 1. release fagn. next. end.
        end.
                  create ast.
                   ast.ast = v-ast.
                   ast.gl = v-gl.
                   ast.crc = 1.
                   ast.fag = v-fag.
                   ast.name = v-name.
                   ast.addr[1] =v-addr.
                   ast.addr[2] = v-addr2.
                   ast.attn = v-attn.
                   ast.rem = v-rem.
                   ast.noy = v-noy.
                   ast.mfc = v-mfc.
                   ast.ser = v-ser.

                   ast.rdt=v-rdt.
    if vo="3" then ast.ldd=g-today.
                   ast.icost=v-icost.
                   ast.ydam[5]=v-ydam5.
                   ast.amt[3]=v-sum.
                   ast.salv=v-salv.
                   ast.qty=v-qty.
                   ast.meth=v-qty.
                   ast.who=g-ofc.
                   ast.whn=g-today.
                   ast.updt=g-today.
                   ast.ofc=g-ofc.

                   ast.ddt[1]=date(1,1,year(g-today)).
                   ast.crline=v-crline.
                   ast.cont=v-cont.
                   ast.ref=string(v-ref).
                   ast.ydam[4]=v-ydam4.
                   ast.ycam[4]=v-ycam4.

     /* sasco - history for AST departments */
     create hist.
     hist.pkey = "AST".
     hist.skey = v-ast.
     hist.date = g-today.
     hist.ctime = time.
     hist.who = g-ofc.
     hist.op = "MOVEDEP".
     hist.chval[1] = v-attn.  /* куда */
     hist.chval[2] = " - ".   /* откуда */
     hist.chval[3] = " - ".   /* откуда - инв. номер */
     hist.chval[4] = v-addr2. /* куда - инв. номер */

           /*
            vparam = """" .
           for each w-par break by v-i :
            if not last(v-i) then
            vparam = vparam + trim(w-par.v-value) + vdel.
            else
            vparam = vparam + trim(w-par.v-value) .
           end.


           */

   sumd1=v-sum + v-salv. /*=v-icost.*/
   sumc1=0.
   sumd3=0.
   sumc3=v-salv.
   arem=trim(trim(v-arem[1]) + " " + trim(v-arem[2]) + " " + trim(v-arem[3])).

   shcode="AST0002".
   vparam=string(sumd1 - sumc3) + vdel +   /* atlik.vert */
          ast.ast               + vdel +
          kor-acc               + vdel +
          arem                  + vdel +
          string(sumc3)         + vdel +         /* noliet */
          string(v-fond)        + vdel +         /* fond parv. */
          kor-acc1              .


   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes,
              input-output s-jh).
   if rcode > 0 or s-jh = 0  then
   do:
         Message " Error: " + string(rcode) + ":" +  rdes .
         pause .
         undo,next m1.
   end.
   else
   do:
    create sh-jh.
    sh-jh.jh = s-jh.
      /*.   run ast-jln(output otv).
         if otv =false then undo,next m1.
      tagad zdes .*/
      create astjln.
      astjln.ajh = s-jh.
      astjln.aln = 1.
      astjln.awho = g-ofc.
      astjln.ajdt = g-today.
      astjln.arem[1]=substring(v-arem[1],1,55).
      astjln.arem[2]=substring(v-arem[2],1,55).
      astjln.arem[3]=substring(v-arem[3],1,55).
      astjln.arem[4]=substring(v-arem[4],1,55).

      astjln.d[1]=sumd1.
      astjln.c[1]=sumc1.
      astjln.d[3]=sumd3.
      astjln.c[3]=sumc3.
      astjln.d[4]=v-ycam4.
      astjln.c[4]=v-ydam4.
       /*.
          astjln.aamt = v-sum.
       .*/
      if vidop="D" then do:
        astjln.dam= sumd1.
        astjln.adc = "D".
      end.
      else do:
        astjln.cam= sumc1.
        astjln.adc = "C".
      end.

      astjln.agl = v-gl.
      astjln.aqty= v-qty.
      astjln.aast = v-ast.
      astjln.afag = v-fag.
      astjln.atrx= v-atrx.
      astjln.ak=v-cont.
      astjln.crline=v-crline.
      astjln.prdec[1]=v-ydam5.
      astjln.icost=v-icost.
      astjln.korgl=kor-gl.
      astjln.koracc=kor-acc.
      astjln.vop=vop.
      /*astjln.kpriz= " " + string(vop) + " " + string(kor-gl) + " " + kor-acc.
      */
      if (vop=7 and v-atrx="6") or substring(v-atrx,1,1)="9" then
      astjln.apriz="A".
      find ast where ast.ast=v-ast no-lock no-error.
      find first astatl where astatl.agl=v-gl and astatl.ast=v-ast and
           astatl.dt=g-today exclusive-lock no-error.
             if not available astatl then create astatl.
             astatl.ast=v-ast.
             astatl.agl=v-gl.
             astatl.fag=v-fag.
             astatl.dt=g-today.
             astatl.icost=ast.dam[1] - ast.cam[1] . /*ast.icost.*/
             astatl.nol=  ast.cam[3] - ast.dam[3].
             astatl.fatl[4]= ast.cam[4] - ast.dam[4].
             astatl.atl=astatl.icost - astatl.nol.
             astatl.qty=ast.qty.


       run x-jlvouR.
       pause 0 .
       klud=false.
       v-mqty = v-mqty - 1.
     end.
   end.
 end. /* tranz*/
/* n */

leave.
end. /*repeat m1*/


leave.
end. /*ma*/


if klud then do transaction:
                 find fagn where fagn.fag=v-fag exclusive-lock no-error.
                 if v-ast=string(v-fag + string(fagn.pednr - 1, "99999")) then
                  fagn.pednr= fagn.pednr - 1.
                 release fagn.
                 return.
end.

release ast.
release astatl.
release astjln.
if rcode = 0 and not klud then repeat:
  otv=false.
  message "  Повторить печать?  " UPDATE otv format "да/нет".
 if  otv then do:
    for each sh-jh no-lock.
        s-jh = sh-jh.jh.
        message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
        run x-jlvouR.  pause 0.
    end.
 end.
 else leave.
end.



