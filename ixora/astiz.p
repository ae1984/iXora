/* astiz.p
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
        10.02.10 marinav - расширение поля счета до 20 знаков
        03/07/2012 Luiza - проверка для ОС имеющих остаточную стоимость по СЗ от 03/07/2012
        24/05/2013 Luiza - ТЗ 1842 закрепление ОС за сотрудником
        12/06/2013 Luiza - ТЗ 1801
*/


/*likv.p     6 or 4*/
def new shared var s-jh like jh.jh.
def new shared var s-aah as int.
def new shared var s-force as log init false.
def new shared var s-consol like jh.consol.
def new shared var s-line as int.
def buffer xaaa for aaa.
def var bila like aaa.cbal label "BILANCE".

def input parameter vo as char.

def new shared var v-ast like ast.ast format "x(8)".
def new shared var v-gl  like ast.gl.
def new shared var v-gl3  like ast.gl.
def new shared var v-gl4  like ast.gl.
def new shared var v-qty like ast.qty format "zzz,zz9".
def new shared var v-fag as char format "x(3)".
def new shared var v-sum as dec format "zzz,zzz,zz9.99".
def new shared var v-cont like ast.cont format "x".
def new shared var v-crline as dec format "zzzzzzz9.99-" init 0.
def new shared var v-ydam5 as dec format "zzzzzzz9.99-" init 0.
def new shared var v-icost like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-nol  like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-atl  like ast.icost format "zzzzzzzz,zz9.99".
def var v-fond like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-sum1 like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-sumd like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-sumr like ast.icost format "zzzzzz,zzz,zz9.99".
def var v-name like ast.name.
def var v-mfc like ast.mfc format "x(30)".
def var v-rem like ast.rem.
def var v-ser like ast.ser.
def var v-noy like ast.noy.
def var v-rdt like ast.rdt.
def var v-salv like ast.salv.
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
def new shared var v-arem as char extent 5 format "x(55)".
def new shared var vop as int.
def new shared var kor-gl like jl.gl.
def new shared var kor-acc like arp.arp.
def new shared var kor-gl1 like jl.gl.
def new shared var kor-acc1 like arp.arp.
def new shared var kor-gld like jl.gl.
def new shared var kor-accd like arp.arp.
def new shared var kor-glr like jl.gl.
def new shared var kor-accr like arp.arp.
def var subld as char.
def var sublr as char.
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
def var gg-crc as int.

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
def var v-str2c as char.
def var v-str2d as char.
def var v-str3d as char.
def var v-str3c as char.
def var v-str4d as char.
def var v-str4c as char.




def var v-str2 as char.
def var v-str3 as char.
def var v-str4 as char.
def var v-str5 as char.


{global.i}
/*
form
"     Счет                              Субсчет   Дебет           Кредит  Вал.1" skip
"-----------------------------------------------------------------------------" skip
"001"   v-gl  v-gln format "x(27)"       v-ast           skip
       v-name at 12 format "x(30)"     "0.00"  to 55     v-sum  to 72 skip
"002"   kor-gl  v-gldes format "x(27)"  kor-acc  skip
v-kdes  at 12  format "x(30)"           v-sum1 to 55     "0.00" to 72 skip
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor overlay centered no-labels row 11.
*/



form
  "ГРУППА     :" v-fag  v-fagn format "x(25)" "СЧЕТ :" v-gl v-gln format "x(17)" skip
  "КАРТОЧКА   :" v-ast format 'x(28)'  " ИНВ. Nr." v-addr2 format "x(20)" skip
  "НАЗВАНИЕ   :" v-name  skip
  "ПРИМЕЧАНИЕ :" v-rem         " Дата регист.:" at 45 v-rdt  skip
  "------------------  Дата  выбытия       " g-today " ------------------" skip
  "КОЛИЧЕСТВО ОС    :" v-qty   "БАЛАНС.СТОИМ.  :" at 38 v-icost skip
  "ОСТАТОЧНАЯ СТОИМ.:" v-atl   "ИЗНОС          :" at 38 v-nol  skip
                               "ФОНД ПЕРЕОЦЕНКИ:" at 38 v-fond  skip
/*
  "--------------- Данные для расчета налога  -----------------------------" SKIP
  "   НАЛОГ.КАТЕГОРИЯ  :" v-cont "  СТАВКА ИЗНОСА :" v-ref  " % x 2 "skip(1)
  "ОСТАТ.СТОИМ.ДЛЯ НАЛ НА" v-ddt  v-crline " тек.года изм." v-ydam5 skip
*/
  "------------------------------------------------------------------------" skip
  "ОТВЕТСТВ.ЛИЦО:" v-addr " " v-addrn skip
  "МЕСТО РАСПОЛ.:" v-attn " " v-attnn skip(1)
 with frame ast row 1 overlay centered no-label
                 title "  " + v-arem[1] + " ОС ".




klud=true.
ma:
repeat on endkey undo,return:
hide all.
  if      vo="1" then  v-atrx="6".
  else if vo="8" then  v-atrx="86".
                 else  v-atrx="4".
  vidop="C".
 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.

 update v-ast validate(v-ast ne ""," ВВЕДИТЕ НОМЕР КАРТОЧКИ   " )
    with frame ast.
 find ast where ast.ast=v-ast no-lock no-error.
  if not avail ast then do: message "КАРТОЧКИ НЕТ ". pause 5. next. end.
  if ast.dam[1] - cam[1] eq 0 then do: message "ОСТАТОК  0 ". pause 5. return.
                                   end.
/*
  if (ast.crline ne 0 or ast.ydam[5] ne 0) and
     year(ast.ddt[1])<year(g-today) then do:
    message "НЕ РАССЧИТАН ИЗНОС ДЛЯ НАЛОГА ЗА "
     + string(year(ast.ddt[1])) + " г.". pause 5. return.
  end.
*/
  /*if (ast.dam[1] - ast.cam[1]) - (ast.cam[3] - ast.dam[3]) <> 0 then do:
      if ast.ldd ne ? and ast.noy ne 0 and
         ast.ldd< date(month(g-today),1,year(g-today))
         and (ast.dam[1] - ast.cam[1] > 1) then
         do: message "НАЧИСЛИТЕ ИЗНОС (посл.начисл." + string(ast.ldd) + ")".
             pause 5. return.
         end.
  end.
  if ast.ldd eq ? and ast.noy ne 0 and
     ast.rdt< date(month(g-today),1,year(g-today))
     then
     do: message "НАЧИСЛИТЕ ИЗНОС ". pause 5. return.
     end.
*/
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

 displ  v-fag v-fagn v-ast v-addr2 v-gl v-gln v-qty  v-rdt v-name v-mfc
        v-rem  /* v-ref v-cont v-ddt v-crline v-ydam5 */
        v-addr v-addrn v-attn v-attnn v-atl v-icost v-nol v-fond g-today
        with frame ast.

do on error undo,retry on endkey undo,next ma:
 update v-qty validate(v-qty >0 and v-qty <= ast.qty , " кол-во " + string(ast.qty))
         with frame ast.
   v-icost = round(v-icost / ast.qty * v-qty,2).
   v-nol = round(v-nol / ast.qty * v-qty,2).
   v-fond = round(v-fond / ast.qty * v-qty,2).
   v-atl=v-icost - v-nol.
   disp v-atl v-nol v-icost v-fond with frame ast. pause 0.

  do /* on endkey undo,next*/ :
   update v-icost validate(v-icost >0 and v-icost <= ast.dam[1] - ast.cam[1],
                       " БАЛАНС.СТОИМОСТЬ " + string(ast.dam[1] - ast.cam[1]))
          v-nol validate(v-nol >=0 and v-nol <= ast.cam[3] - ast.dam[3],
                         ">0 un <=  " + string(ast.cam[3] - ast.dam[3]))
          v-fond validate(v-fond >=0 and v-fond <= ast.cam[4] - ast.dam[4],
                          " фонд <= " + string(ast.cam[4] - ast.dam[4]))
          with frame ast.
   v-atl=v-icost - v-nol.
   displ v-atl with frame ast.

   if v-qty = ast.qty and not (v-icost = ast.dam[1] - ast.cam[1] and
      v-nol = ast.cam[3] - ast.dam[3] and v-fond = ast.cam[4] - ast.dam[4])
      then do: message "Проверьте суммы". pause 3. undo,retry. end.

  end.


 find asttr where asttr.asttr=v-atrx no-lock no-error.
 if avail asttr then v-arem[1]=asttr.atdes.
  v-arem[1]=v-arem[1] + " " + trim( v-name) + ".".
  v-arem[2]="Баланс.ст. " + trim(string(v-icost,"zzzzzzzz9.99-")) + " " +
         kodcrc +  " износ " + trim(string(v-nol,"zzzzzzzz9.99-")).
  if v-fond >0 then
   v-arem[3]= " фонд переоценки " + trim(string(v-fond,"zzzzzzzz9.99-")).


/*..
  if vo="2" then v-crline=round(v-crline / ast.qty * v-qty,2).
            else v-crline=0.
  v-ydam5=round(v-ydam5 / ast.qty * v-qty,2).

   if v-sum<1 and v-qty<>ast.qty then next ma.

/*  update v-sum validate(v-sum >0 and v-sum <= ast.qty ," ")
        with frame ast.
*/
 disp v-sum v-nol v-icost v-crline v-ydam5 with frame ast. pause 0.

 v-arem[1]=v-arem[1] + " Перв.ст. " + trim(string(v-icost,"zzzzzzzz9.99-")) +
         crc-cod +  " износ" + trim(string(v-nol,"zzzzzzzz9.99-")).
 v-arem[2]=v-arem[2] + " " + v-name + ".".
 if vo="2" then do:
  v-arem[2]="Ост.ст.нал.на" + string(v-ddt) + " " + crc-cod + " " +
            trim(string(v-crline,"zzzzzzzz9.99-")).
            if v-ydam5 ne 0 then v-arem[2]= v-arem[2] + " тек.г.изм." +
            trim(string(v-ydam5,"zzzzzzz9.99-")).
            v-arem[2]=v-arem[2] + " кат." + v-cont + " " + ast.ref + "%x2".
  v-arem[2]=substr(v-arem[2],1,55).
  v-arem[3]=trim(substr(v-arem[2],56,55)).
  v-arem[3]=v-arem[3] + " " + v-name + ".".
 end.
..*/

 otv=true.
 message "  ПРОДОЛЖИТЬ ?  " UPDATE otv format "да/нет".
 if not otv then next ma.

end.


m1:
repeat on error undo,retry on endkey undo,next ma:

/*if vo="8" then vop=1. */


      v-str1d=string(v-gl3,"zzzzz9") + " " +
            substring(v-gl3d + "                                      ",1,29)
            + substring(v-ast,1,10) + "       " +
            string(v-nol,"zzz,zzz,zzz,zz9.99") + "  DR".
      v-str1c=string(v-gl,"zzzzz9") + " " +
            substring(v-gln + "                                      ",1,29)
            + substring(v-ast,1,10) + "       " +
            string(v-nol,"zzz,zzz,zzz,zz9.99") + "  CR".



 if v-atrx="4" then do:

      v-str2=string(v-gl,"zzzzz9") + " " +
            substring(v-gln + "                                      ",1,29)
            + substring(v-ast,1,10) + "       " +
            string(v-atl,"zzz,zzz,zzz,zz9.99") + "  CR".


form
"     Счет                              Субсчет              Сумма " kodcrc skip
"-----------------------------------------------------------------------------" skip
""   v-str1d  format "x(88)"  skip
""   v-str1c  format "x(88)"  skip
""   v-str2  format "x(88)"  skip
""  kor-gl  v-gldes format "x(28)"   kor-acc      v-atl to 81 " DR" skip
 v-kdes  at 12  format "x(30)"            skip
  skip(4)
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor4 overlay  no-labels row 6 width 100.

form
""  v-str4 format "x(85)"  skip
""  kor-gl1  v-gldes1 format "x(28)"  kor-acc1      v-fond to 81 " DR" skip
       v-kdes1  at 12  format "x(30)"            skip
 with frame kor41 overlay column 2 no-labels row 15 width 100 no-box.

form
" ОПИСАНИЕ:"  v-arem[1] at 11  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor42 overlay no-labels row 18 column 2 no-box.




    displ v-str1d v-str1c v-str2  v-atl  v-arem[1] v-arem[2] v-arem[3]
         kor-gl kor-acc v-gldes  kodcrc
         with frame kor4.

    message " Введите номер ARP".
   update kor-acc with frame kor4.
   find arp where arp.arp eq kor-acc no-lock no-error.
   if not available arp then do: bell. {mesg.i 2203}. undo,retry. end.
   if arp.crc <> ast.crc then do: bell. {mesg.i 9813}. undo,next. end.
   kor-gl=arp.gl.
   v-kdes=arp.des.
   displ kor-gl v-kdes with frame kor4.
   find gl where gl.gl=kor-gl no-lock no-error.
   if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
   v-gldes=gl.des. displ v-gldes with frame kor4. pause 0.
   kor-acc1=kor-acc.
   if v-fond  ne 0 then do:

      v-str4=string(v-gl4,"zzzzz9") + " " +
             substring(v-gl4d + "                                    ",1,29)
           + substring(v-ast,1,10) + "                  " +
             string(v-fond,"zzz,zzz,zzz,zz9.99") + "  cR".
      displ v-str4  v-fond with frame kor41.
      message " Введите номер ARP".
      update kor-acc1 with frame kor41.
      find arp where arp.arp eq kor-acc1 no-lock no-error.
      if not available arp then do: bell. {mesg.i 2203}. undo,retry. end.
      if arp.crc <> ast.crc then do: bell. {mesg.i 9813}. undo,next. end.
      kor-gl1=arp.gl.
      v-kdes1=arp.des.
      displ kor-gl1 v-kdes1 with frame kor41.
      find gl where gl.gl=kor-gl1 no-lock no-error.
      if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
      v-gldes1=gl.des. displ v-gldes1 with frame kor41.

   end.

   update v-arem[1] v-arem[2] v-arem[3] with frame kor42.


 end. /* 4 */

 else do:  /* 6 */

form
"     Счет                              Субсчет              Сумма " kodcrc skip
"-----------------------------------------------------------------------------" skip
""   v-str1d  format "x(77)"  skip
""   v-str1c  format "x(77)"  skip
""   v-str2d  format "x(77)"  skip
""   v-str2c  format "x(77)"  skip
""   v-str3d  format "x(77)"  skip
""  kor-gld  v-gldesd format "x(28)"   kor-accd      v-sumd to 81 v-str3c skip
    v-kdesd  at 12  format "x(30)"            skip
""  kor-glr  v-gldesr format "x(28)"   kor-accr      v-sumr to 81 v-str4d skip
    v-kdesr  at 12  format "x(30)"            skip
""   v-str4c  format "x(77)"  skip

  skip
"ОПИСАНИЕ:" v-arem[1]  skip v-arem[2] at 11 skip v-arem[3] at 11
 with frame kor6 overlay  no-labels row 5  width 100.

   displ v-str1d v-str1c  kodcrc with frame kor6.

   if v-fond > 0 then do:

     if v-fond>v-atl then v-sum1=v-atl.
                     else v-sum1=v-fond.

           v-str2d=string(v-gl4,"zzzzz9") + " " +
                substring(v-gl4d + "                                      ",1,29)
                + substring(v-ast,1,10) + "                  " +
                string(v-sum1,"zzz,zzz,zzz,zz9.99") + "  DR".
           v-str2c=string(v-gl,"zzzzz9") + " " +
                  substring(v-gln + "                                      ",1,29)
                 + substring(v-ast,1,10) + "                  " +
                  string(v-sum1,"zzz,zzz,zzz,zz9.99") + "  CR".
         displ v-str2d v-str2c    with frame kor6.
   end.

   if v-fond>v-atl then do:

         v-sumd=v-fond - v-atl.
         v-sumr=0.

         v-str3d=string(v-gl4,"zzzzz9") + " " +
                substring(v-gl4d + "                                      ",1,29)
                + substring(v-ast,1,10) + "                  " +
                string(v-sumd,"zzz,zzz,zzz,zz9.99") + "  DR".
         v-str3c=" CR".
         v-str4d="". v-str4c="".
         displ v-str2d v-str2c v-str3d v-str3c v-sumd  with frame kor6.


    message " Введите номер счета доходов ".
    update kor-accd with frame kor6.
    if kor-accd ne "" then do:
      find eps where eps.eps eq kor-accd no-lock no-error.
      if not available eps then do: bell. {mesg.i 2203}. undo,retry. end.
      if eps.crc <> ast.crc then do: bell. {mesg.i 9813}. undo,next. end.
      kor-gld=eps.gl.
      v-kdesd=eps.des.
      subld="eps".
      displ kor-gld v-kdesd with frame kor6.
    end.
    else do: update kor-gld with frame kor6.
            find gl where gl.gl=kor-gld and gl.subled eq "" no-lock no-error.
            if not available gl then do: bell. {mesg.i 2203}. undo,retry. end.
            subld="".
    end.
    find gl where gl.gl=kor-gld no-lock no-error.
    if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
    v-gldesd=gl.des. displ v-gldesd with
    frame kor6. pause 0.

    kor-glr =kor-gld.
    kor-accr=kor-accd.
    sublr   =subld.
   end.
   else do:
         v-sumd=0.
         v-sumr=v-atl - v-fond.
         v-str3d="". v-str3c="".
         v-str4d=" DR".
         v-str4c=string(v-gl,"zzzzz9") + " " +
                substring(v-gln + "                                      ",1,29)
                + substring(v-ast,1,10) + "                  " +
                string(v-sumr,"zzz,zzz,zzz,zz9.99") + "  CR".
         displ v-str2d v-str2c v-str3d  v-str4d v-str4c v-sumr  with frame kor6.


    message " Введите номер счета расходов".
    update kor-accr with frame kor6.
    if kor-accr ne "" then do:
      find eps where eps.eps eq kor-accr no-lock no-error.
      if not available eps then do: bell. {mesg.i 2203}. undo,retry. end.
      if eps.crc <> ast.crc then do: bell. {mesg.i 9813}. undo,next. end.
      kor-glr=eps.gl.
      v-kdesr=eps.des.
      sublr="eps".
      displ kor-glr v-kdesr with frame kor6.
    end.
    else do: update kor-glr with frame kor6.
            find gl where gl.gl=kor-glr and gl.subled eq "" no-lock no-error.
            if not available gl then do: bell. {mesg.i 2203}. undo,retry. end.
            subld="".
    end.
    find gl where gl.gl=kor-glr no-lock no-error.
    if gl.sts eq 9 then do: bell. {mesg.i 1827}. undo,next. end.
    v-gldesr=gl.des. displ v-gldesr with frame kor6. pause 0.

    kor-gld =kor-glr.
    kor-accd=kor-accr.
    subld   =sublr.

   end.


   update v-arem[1] v-arem[2] v-arem[3] with frame kor6.

  end. /* 6 */


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

  if v-atrx="4" then do:
   shcode="AST0007".
   vparam=string(v-nol)         + vdel +
          v-ast                 + vdel +
          arem1                 + vdel +
          string(v-atl)         + vdel +
          kor-acc               + vdel +
          arem2                 + vdel +
          string(v-fond)        + vdel +
          kor-acc1              .
  end.
  else do:
   shcode="AST0006".
   vparam=string(v-nol)         + vdel +
          v-ast                 + vdel +
          arem1                 + vdel +
          string(v-sum1)        + vdel +
          string(v-sumd)        + vdel +
          string(kor-gld)       + vdel +
          subld                 + vdel +
          kor-accd              + vdel +
          string(v-sumr)        + vdel +
          string(kor-glr )      + vdel +
          sublr                 + vdel +
          kor-accr              + vdel +
          arem2                 .
  end.

   s-jh = 0.
   run trxgen(shcode,vdel,vparam,"","",output rcode,output rdes,
              input-output s-jh).
   if rcode > 0 or s-jh = 0  then
   do:
         Message " Error: " + string(rcode) + ":" +  rdes .
         pause .
         undo,return . /*next ma.*/
   end.
   else
   do:
           find ast where ast.ast=v-ast exclusive-lock.
                   ast.icost= ast.dam[1] - ast.cam[1].
                   ast.qty= ast.qty - v-qty.
                   ast.crline= ast.crline - v-crline.
                   ast.ydam[5]= ast.ydam[5] - v-ydam5.
                   ast.ofc=g-ofc.
                   ast.updt=g-today.
      create astjln.
      astjln.ajh = s-jh.
      astjln.aln = ast.crc.
      astjln.awho = g-ofc.
      astjln.ajdt = g-today.
      astjln.arem[1]=substring(v-arem[1],1,55).
      astjln.arem[2]=substring(v-arem[2],1,55).
      astjln.arem[3]=substring(v-arem[3],1,55).
      astjln.arem[4]=substring(v-arem[4],1,55).

      astjln.d[1]=0.
      astjln.c[1]=v-icost.
      astjln.d[3]=v-nol.
      astjln.c[3]=0.
      astjln.d[4]=v-fond.
      astjln.c[4]=0.

        astjln.adc = "C".
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
      find first astatl where astatl.agl=ast.gl and astatl.ast=ast.ast and
           astatl.dt=g-today exclusive-lock no-error.
             if not available astatl then create astatl.
             astatl.ast=ast.ast.
             astatl.agl=ast.gl.
             astatl.fag=ast.fag.
             astatl.dt=g-today.
             astatl.icost=ast.dam[1] - ast.cam[1] . /*ast.icost.*/
             astatl.nol=  ast.cam[3] - ast.dam[3].
             astatl.fatl[4]= ast.cam[4] - ast.dam[4].
             astatl.atl=astatl.icost - astatl.nol.
             astatl.qty=ast.qty.




       run x-jlvouR.
       pause 0 .
       klud=false.
   end.
 end. /* tranz*/
/* n */

release ast.
release astatl.
release astjln.
if rcode = 0 and not klud then repeat:
  otv=false.
  message "  Повторить печать?  " UPDATE otv format "да/нет".
 if  otv then do:
    message "ПЕЧАТЬ ОРДЕРА # " + string(s-jh) + " ".
    run x-jlvouR.  pause 0.
 end.
 else leave.
end.



