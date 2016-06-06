/* checgram.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
       15.07.99 - перевод на генератор транзакций
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       07.10.05 dpuchkov добавил серию чека
       21.10.05 dpuchkov добавил проверку на латинские буквы в серии чека
       15.11.2010  marinav - поискать исключения по тарифам
       10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
       10.06.2011 aigul - проверка срока действия УЛ
       25/04/2012 dmitriy - Автозаполнение последнего номера чековой книжки.
       28/06/2012 dmitriy - добавил поле bank при создании записи в checks
       25/09/2012 dmitriy - поле checks.pages - список неиспользованных листов ЧК
 */

/*
добавлено условие на продажу книжек с 50-ю листами - фрагмент выделен ./---/
*/


{mainhead.i}


define new shared variable s-consol like jh.consol initial false.
define new shared variable s-jh like jh.jh.
define new shared variable s-aah as int.
define new shared variable s-aax as int.
def new shared var l-aaa like aaa.gl.
define new shared variable s-intr as log init true.
define new shared variable s-amt as dec.
define new shared variable s-aaa like aaa.aaa.
define new shared variable s-cif like cif.cif.
define new shared variable s-bal as dec.
define new shared variable s-regdt as date.
define new shared variable s-stn as int.
define new shared variable s-line as int.
define new shared variable s-force as logical.

def new shared var srem as char format "x(50)" extent 2.

define new shared variable vln as integer.
define new shared buffer b-aaa for aaa.

def var v1 as integer.
def var v3 as integer.
def var v2 as integer initial 000024.
def var v4 as integer initial 25.
def var v5 as integer initial 000025.
def var ok as int.
def var kk as int.
def var pirno as int.
def var otrno as int.
def new shared var c-ienk as int.
def new shared var c-kask as int.

def new shared var c-konv as int.
def new shared var c-doh as int.
def new shared var c-ras as int.
def new shared var casne as log label 'CASH/NO' init false.
def new shared var ccc like gram.cekcen.
def var c-aaa like aaa.craccnt.
def var s-old like aaa.opnamt.
def new shared var dauccc as deci.
def new shared var coco as deci.
def new shared var coco1 as deci.
def var koko as char.

def new shared var s-cek like gram.cekcen.
def var s-non as int format "9999999".
def var s-nan as int format "9999999".
def var s-lid as int format "9999999".
def var s-ccc like gram.cekcen.
def new shared var s-crc like crc.crc.
def var ssnn as char.
def var crcrate as deci.
def var vasa as log.
def var elita as log.
def new shared var komkom as deci.       /*komision*/
def var sumbal as decimal format "z,zzz,zzz,zzz,zz9.99-".
def var ostbal as decimal format "z,zzz,zzz,zzz,zz9.99-".
def var astbal as decimal format "z,zzz,zzz,zzz,zz9.99-".
def var nnn as int format "9999999".
def var lid as int format "9999999".
def var aaa as int.
def var bbb as int.
def new shared var lena as int.

def var jparr as char.
def var v-param as char.
def var rcode as int.
def var rdes as char.
def var vdel as char initial "^".
def var v-templ as char.
def var ja as logi init false.


def var v-ser as char.
def var v-pages as char.
def var v-num as int format "9999999".
def var i as int.



/* ja - EKNP - 26/03/2002 */
define temp-table w-cods
       field template as char
       field parnum as inte
       field codfr as char
       field what as char
       field name as char
       field val as char.
def var CodesEntered as logi initial false.
/*ja - EKNP - 26/03/2002 */




{checgram.f}

repeat:     /*1*/
    s-cif = " ".
    view frame checgram.
    update s-cif
        validate(can-find (cif where cif.cif = s-cif),
        "Клиент не найден - введите корректно код клиента ")
        with frame checgram.
     run check_ul(s-cif).
     find first cif where cif.cif = s-cif no-lock.
     disp g-today with frame checgram.
     disp trim(trim(cif.prefix) + " " + trim(cif.sname)) @ cif.sname with frame checgram.
     casne = false.
     update casne with frame checgram.

     /* анализ CASH */
    if casne eq false then do:
        s-aaa = " ".
        repeat:
            update s-aaa validate(can-find (aaa where aaa.aaa = s-aaa),
            "Счет не найден - введите корректно номер счета")
            with frame checgram.

            find aaa where aaa.aaa = s-aaa and aaa.cif = s-cif
            no-error. /*no-lock.*/
            if aaa.sta eq "C" then do:
                message "Счет " aaa.aaa  " закрыт".
                undo,retry.
            end.
            run aaa-aas.
            find first aas where aas.aaa = s-aaa and aas.sic = 'SP'
            no-lock no-error.
            if available aas then do: pause. undo,retry. end.
            find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
                if lgr.led eq "ODA" then do:
                    message "Введите корректно номер счета".
                    next.
                end.
            leave.
        end.

        s-crc = aaa.crc.
        disp s-crc with frame checgram.

        find crc where crc.crc = aaa.crc no-lock.
        disp crc.code with frame checgram.
        koko = crc.code.
        crcrate = crc.rate[4].
    end.
    if casne eq true then do: /*kase*/
        s-crc = 0. elita = false.
        update s-crc with frame checgram.
        if s-crc = 1 then elita = true.

        find crc where crc.crc = s-crc no-lock.
        disp crc.code with frame checgram.
        koko = crc.code.
        /*crcrate = crc.rate[2].*/
    end.
M5:
    repeat on error undo, retry:
        update s-non with frame checgram.
        nnn = s-non.

        /*проверка правильности введенного 1 - ого номера*/
        aaa = nnn modulo 25.
        if aaa ne 1 or nnn eq 0 then do:
            bell.
            message "Введите номер корректно".
            undo, retry.
        end.
        else do:
            s-lid = s-non + 24.
            display s-lid with frame checgram.
            /*update s-lid with frame checgram.*/
            lid = s-lid.
            /*проверка правильности введенного последнего номера*/
            bbb = lid modulo 25.
            if bbb ne 0 or lid eq 0 or lid < nnn then do:
                bell.
                message "Введите номер корректно".
                undo, retry.
            end.
            else do:
                pirno = s-non. otrno = s-lid. s-nan = s-non.
                if otrno - pirno = 49 then do:
                   v2 = 000049.
                   v4 = 50.
                   v5 = 000050.
                end.
                kk = (otrno - pirno) / v4.
                ok = 1.
v-ser = "".
update v-ser format "x(2)" validate(v-ser <> "","Введите номер серии") with frame checgram.
v-ser = lower(v-ser).


if lookup(substr(v-ser, 1 ,1),"q,a,z,w,s,x,e,d,c,r,f,v,t,g,b,y,h,n,u,j,m,i,k,l,o,p") <> 0 then do:
   message "Необходимо ввести серию русскими буквами"  view-as alert-box title "".  undo,retry.
end.


                find last gram where gram.non = s-non and gram.ser <> "" and gram.ser = v-ser and gram.bank = "F"
                and (gram.izmatz ne "I" and gram.anuatz ne "*")
                no-error.

                if not available gram then
                find last gram where gram.non = s-non and gram.ser = "" and gram.bank = "F"
                and (gram.izmatz ne "I" and gram.anuatz ne "*")
                no-error.


                if not available gram then do:
                    message
"Чековой книжки с таким номером нет в системе, либо использована(аннулирована)".
                    next M5.
                end.
                if available gram then do:
                   find first tarifex where tarifex.str5 = "151" and tarifex.cif = s-cif and tarifex.stat = 'r' no-lock no-error.
                   if avail tarifex then  gram.cekcen = tarifex.ost .
                   ccc = gram.cekcen.
                end.
                find current gram no-lock.
                dauccc = ccc * kk.
                if s-crc eq 1 then coco = dauccc.
                else do:
                    find crc where crc.crc eq 1 no-lock no-error.
                    coco1 = dauccc * crc.rate[1] / crc.rate[9].

                    find crc where crc.crc eq s-crc no-lock no-error.
                    if s-crc ne 1  then
                    coco = coco1 * crc.rate[9] / crc.rate[1].
                    else coco = coco1.
                end.
                disp coco koko with frame checgram.

                vasa = false.
                {mesg.i 0832} update vasa.
              if vasa then do:
                if casne then do:   /*оплата наличными*/
                    if s-crc eq 1 then do:
                        v-param = string(dauccc) + vdel.
                        v-templ = "BOK0001".
                    end.
                    else do:
                        v-param = string(s-crc)+ vdel + string(dauccc) + vdel.
                        v-templ = "BOK0002".
                    end.
                end.
                else do:
                    if s-crc eq 1 then do:
                        v-param = string(dauccc) + vdel +  string(s-aaa).
                        v-templ = "BOK0003".
                    end.
                    else do:
                        v-param =
                        string(s-aaa) + vdel +  string(dauccc).
                        v-templ = "BOK0004".
                    end.
                end.

                run trxsim("", v-templ,vdel,v-param,"", output rcode,
                output rdes, output jparr).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.

/* ja - EKNP - 26/03/2002 --------------------------------------------*/
        run Collect_Undefined_Codes(v-templ).
        run Parametrize_Undefined_Codes(output CodesEntered).
        if not CodesEntered then do:
           bell.
           message "Не все коды введены! Транзакция не будет создана!"
                   view-as alert-box.
           return "exit".
        end.

           run Insert_Codes_Values(v-templ, vdel, input-output v-param).
/* ja - EKNP - 26/03/2002 --------------------------------------------*/

                s-jh = 0.
                run trxgen (v-templ, vdel, v-param, "CIF" ,"" ,
                output rcode, output rdes, input-output s-jh).
                if rcode ne 0 then do:
                    message rdes.
                    pause.
                    undo, return.
                end.

                if s-jh ne 0 then
                run trxsts(s-jh, 6, output rcode, output rdes).
                find jh where jh.jh = s-jh.
             end.

            /*проверка наличия необходимой суммы на счету клиента*/
            if casne eq false then do:
                komkom = (coco * crc.rate[1]) -
                (coco * crc.rate[4]).
                disp coco koko with frame checgram.
                coco = coco + komkom.

                /*sumbal = aaa.cbal - aaa.hbal. ostbal = sumbal - coco.*/
                /*vasa = false.
                {mesg.i 0832} update vasa.*/

                repeat while ok le kk:
                    find last gram where gram.nono = s-non and gram.ser <> "" and gram.ser = v-ser and gram.bank = "F" and
                    (gram.izmatz ne "I" or gram.anuatz ne "*")
                    no-error.
                    if not available gram then
                    find last gram where gram.nono = s-non and gram.ser = "" and gram.bank = "F" and
                    (gram.izmatz ne "I" or gram.anuatz ne "*")
                    no-error.

                    if not available gram then do :
                        message
"Чековой книжки с таким номером нет в системе, либо использована(аннулирована)".
                        next M5.
                    end.
                    else do:
                        do transaction on error undo, retry:
                            gram.nono = s-non.
                            gram.lidzno = s-non + v2.
                        end.
                        ok = ok + 1.
                        s-non = s-non + v5.
                    end.
                end.  /*repeat*/
                /*if ostbal gt 0 then do:
                    if vasa = true then do:
                        if s-crc = 1 then do:
                            run tr-aga.
                        end.
                        else do:
                            run tr-bur.
                        end.
                    end.
                end.*/
            end. /* beznal */
            if casne eq true then do:     /*kasё*/
                komkom = (coco * crc.rate[1]) - (coco * crc.rate[2]).
                disp coco with frame checgram.
                disp koko with frame checgram.
                coco = coco + komkom.

                /*{mesg.i 0832} update vasa.*/
                ok = 1. /*s-non = s-nan.   */
                repeat while ok le kk:
                    find last gram where gram.nono = s-non and gram.ser <> "" and gram.ser = v-ser and
                    (gram.izmatz ne "I" or gram.anuatz ne "*")
                    no-error.
                    if not available gram then
                    find last gram where gram.nono = s-non and gram.ser = "" and
                    (gram.izmatz ne "I" or gram.anuatz ne "*")
                    no-error.

                    if not available gram then do :
                        message
"Чековой книжки с таким номером нет в системе, либо использованa(аннулирована)".
                        next M5.
                    end.
                    else do:
                        do transaction on error undo, retry:
                            gram.nono = s-non.
                            gram.lidzno = s-non + v2.
                        end.
                        ok = ok + 1.
                        s-non = s-non + v5.
                    end.
                end.
            end.
            /*if vasa = true then do:         /*если подтверждается продажа*/
                if s-crc = 1 then do:
                    run tr-aga. /*для латовых расчетов*/
                end.
                else do:
                    run tr-bur.        /*для расчетов в валюте*/
                end.
            end.*/

            ok = 1. s-non = s-nan.

            if vasa = true then do:         /*если подтверждается продажа*/
                repeat while ok le kk:
                    find last gram where gram.nono = s-non and gram.bank = "F" and gram.ser <> "" and gram.ser = v-ser and
                    (gram.izmatz ne "I" or gram.anuatz ne "*")
                    no-error.

                    if not available gram then
                    find last gram where gram.nono = s-non and gram.bank = "F" and gram.ser = "" and
                    (gram.izmatz ne "I" or gram.anuatz ne "*")
                    no-error.




                    if not available gram then do :
                        message
 "Чековой книжки с таким номером нет в системе. Введите другой номер".
                        undo,retry.
                    end.
                    else do:
                        do transaction on error undo, retry:
                            gram.nono = s-non.
                            gram.cif = s-cif.
                            gram.lidzno = s-non + v2.
                            gram.izmatz = "I".
                            gram.atzdat = g-today.
                            gram.atzwho = g-ofc.
                        end.

                        find checks where checks.nono = s-non and checks.ser <> "" and checks.ser = v-ser and checks.bank = "F" no-error.

/*                      if not available checks then
                        find checks where checks.nono = s-non and checks.ser = "" no-error. */



                        if not available checks then do transaction:
                            create checks.
                            checks.nono = s-non.
                            checks.lidzno = s-non + v2.
                            checks.cif = s-cif.
                            checks.regdt = g-today.
                            checks.who = g-ofc.
                            checks.jh = s-jh.
                            checks.ser = v-ser.
                            checks.bank = "F".

                            v-num = s-non.
                            do i = 1 to 25 :
                                v-pages = v-pages + string(v-num) + "|" .
                                v-num = v-num + 1.
                            end.
                            checks.pages = v-pages.

                        end.
                        else do:
                           message "Чековая книжка с таким номером уже продана".
                           leave.
                        end.
                        ok = ok + 1.
                        s-non = s-non + v5.
                    end. /*prodaem!!!*/
                end. /*repeat while ok*/
            end. /*confirm*/
            else leave.
            leave.
        end. /*else do: - vse korrektno*/
    end. /*repeat*/
end.
/*vaucher*/

                do on endkey undo:
                    message "Печатать ваучер ?" update ja.
                    if ja then do:
                        find first jl where jl.jh = s-jh no-error.
                        if available jl  then do:
                            {mesg.i 0933} s-jh.
                            s-jh = jh.jh.
                            run x-jlvou.
                            if jh.sts < 5 then jh.sts = 5.
                            for each jl of jh:
                                if jl.sts < 5 then jl.sts = 5.
                            end.
                        end.  /* if available jl */
                        else do:
                            message "Can't find transaction " s-jh.
                            return.
                        end.
                    end. /* if ja */
                    pause 0.
                end.
                /*транзакция уже с 6 статусом
                pause 0.
                ja = no.
                message "Штамповать ?" update ja.
                if ja then run jl-stmp.
                */


clear frame checgram. /* no-pause.*/
end.

/*ja - EKNP - 26/03/2002 -------------------------------------------*/
Procedure Collect_Undefined_Codes.

def input parameter c-templ as char.
def var vjj as inte.
def var vkk as inte.
def var ja-name as char.
for each w-cods:
   delete w-cods.
end.
for each trxhead where trxhead.system = substring (c-templ, 1, 3)
             and trxhead.code = integer(substring(c-templ, 4, 4)) no-lock:

    if trxhead.sts-f eq "r" then vjj = vjj + 1.

    if trxhead.party-f eq "r" then vjj = vjj + 1.

    if trxhead.point-f eq "r" then vjj = vjj + 1.

    if trxhead.depart-f eq "r" then vjj = vjj + 1.

    if trxhead.mult-f eq "r" then vjj = vjj + 1.

    if trxhead.opt-f eq "r" then vjj = vjj + 1.

    for each trxtmpl where trxtmpl.code eq c-templ no-lock:

        if trxtmpl.amt-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crc-f eq "r" then vjj = vjj + 1.

        if trxtmpl.rate-f eq "r" then vjj = vjj + 1.

        if trxtmpl.drgl-f eq "r" then vjj = vjj + 1.

        if trxtmpl.drsub-f eq "r" then vjj = vjj + 1.

        if trxtmpl.dev-f eq "r" then vjj = vjj + 1.

        if trxtmpl.dracc-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crgl-f eq "r" then vjj = vjj + 1.

        if trxtmpl.crsub-f eq "r" then vjj = vjj + 1.

        if trxtmpl.cev-f eq "r" then vjj = vjj + 1.

        if trxtmpl.cracc-f eq "r" then vjj = vjj + 1.

        repeat vkk = 1 to 5:
            if trxtmpl.rem-f[vkk] eq "r" then vjj = vjj + 1.
        end.

        for each trxcdf where trxcdf.trxcode = trxtmpl.code
                          and trxcdf.trxln = trxtmpl.ln:

         if trxcdf.drcod-f eq "r" then do:
             vjj = vjj + 1.

             find first trxlabs where trxlabs.code = trxtmpl.code
                                  and trxlabs.ln = trxtmpl.ln
                                  and trxlabs.fld = trxcdf.codfr + "_Dr"
                                                        no-lock no-error.
             if available trxlabs then ja-name = trxlabs.des.
             else do:
               find codific where codific.codfr = trxcdf.codfr no-lock no-error.
               if available codific then ja-name = codific.name.
               else ja-name = "Неизвестный кодификатор".
             end.
            create w-cods.
                   w-cods.template = c-templ.
                   w-cods.parnum = vjj.
                   w-cods.codfr = trxcdf.codfr.
                   w-cods.name = ja-name.
         end.

         if trxcdf.crcode-f eq "r" then do:
             vjj = vjj + 1.

             find first trxlabs where trxlabs.code = trxtmpl.code
                                  and trxlabs.ln = trxtmpl.ln
                                  and trxlabs.fld = trxcdf.codfr + "_Cr"
                                                        no-lock no-error.
             if available trxlabs then ja-name = trxlabs.des.
             else do:
               find codific where codific.codfr = trxcdf.codfr no-lock no-error.
               if available codific then ja-name = codific.name.
               else ja-name = "Неизвестный кодификатор".
             end.
            create w-cods.
                   w-cods.template = c-templ.
                   w-cods.parnum = vjj.
                   w-cods.codfr = trxcdf.codfr.
                   w-cods.name = ja-name.
         end.
  end.
    end. /*for each trxtmpl*/
end. /*for each trxhead*/

End procedure.

Procedure Parametrize_Undefined_Codes.

  def var ja-nr as inte.
  def output parameter CodesEntered as logi initial false.
  def var jrcode as inte.
  def var saved-val as char.

  find first w-cods no-error.
  if not available w-cods then do:
    CodesEntered = true.
    return.
  end.

{jabrew.i
   &start = " on help of w-cods.val in frame lon_cods do:
                  run uni_help1(w-cods.codfr,'*').
              end.
              vkey = 'return'.
              key-i = 0. "

   &head = "w-cods"
   &headkey = "parnum"
   &where = "true"
   &formname = "lon_cods"
   &framename = "lon_cods"
   &deletecon = "false"
   &addcon = "false"
   &prechoose = "message 'F1-сохранить и выйти; F4-выйти; Enter-редактировать; F2-помощь'."
   &predisplay = " ja-nr = ja-nr + 1. "
   &display = "ja-nr /*w-cods.codfr*/ w-cods.name /*w-cods.what*/ w-cods.val"
   &highlight = "ja-nr"
   &postkey = "else if vkeyfunction = 'return' then do:
               valid:
               repeat:
                saved-val = w-cods.val.
                update w-cods.val with frame lon_cods.
                find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                if not available codfr or codfr.code = 'msc' then do:
                   bell.
                   message 'Некорректное значение кода! Введите правильно!'
                           view-as alert-box.
                   w-cods.val = saved-val.
                   display w-cods.val with frame lon_cods.
                   next valid.
                end.
                else leave valid.
               end.
                if crec <> lrec and not keyfunction(lastkey) = 'end-error' then do:
                  key-i = 0.
                  vkey = 'cursor-down^return'.
                end.
               end.
               else if keyfunction(lastkey) = 'GO' then do:
                   jrcode = 0.
                 for each w-cods:
                  find codfr where codfr.codfr = w-cods.codfr
                             and codfr.code = w-cods.val no-lock no-error.
                  if not available codfr or codfr.code = 'msc' then jrcode = 1.
                 end.
                 if jrcode <> 0 then do:
                    bell.
                    message 'Введите коды корректно!' view-as alert-box.
                    ja-nr = 0.
                    next upper.
                 end.
                 else do: CodesEntered = true. leave upper. end.
               end."
   &end = "hide frame lon_cods.
           hide message."
}

End procedure.

Procedure Insert_Codes_Values.

def input parameter t-template as char.
def input parameter t-delimiter as char.
def input-output parameter t-par-string as char.
def var t-entry as char.

for each w-cods where w-cods.template = t-template break by w-cods.parnum:
   t-entry = entry(w-cods.parnum,t-par-string,t-delimiter) no-error.
   if ERROR-STATUS:error then
      t-par-string = t-par-string + t-delimiter + w-cods.val.
   else do:
      entry(w-cods.parnum,t-par-string,t-delimiter) = t-delimiter + t-entry.
      entry(w-cods.parnum,t-par-string,t-delimiter) = w-cods.val.
   end.
end.

End procedure.
/*ja - EKNP - 26/03/2002 ------------------------------------------*/
