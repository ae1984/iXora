/* cs_data.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        22.02.2013 evseev
 * BASES
        BANK COMM
 * CHANGES
        31.05.2013 tz-1810
*/

{global.i}

def /*new*/ shared var s-credtype as char init '4' no-undo.
def /*new*/ shared var v-aaa      as char no-undo.
def /*new*/ shared var v-bank     as char no-undo.
def /*new*/ shared var v-cifcod   as char no-undo.

def var v-maillist as char.
def var v-zag      as char.
def var v-str      as char.

def var i as int.
find first codfr where codfr.codfr = 'clmail' and codfr.code = 'oomail' no-lock no-error.
if not avail codfr then do:
    message 'Нет справочника адресов рассылки' view-as alert-box.
    return.
end.
else do:
    i = 1.
    do i = 1 to num-entries(codfr.name[1],','):
        v-maillist = v-maillist + entry(i,codfr.name[1],',') + '@fortebank.com,'.
    end.
end.

/*
v-aaa = "KZ11470192204A909416".
v-bank = "txb16".
v-cifcod = "T16705".
*/
def var v-companyName as char init '' no-undo.
def buffer b-cif for cif.
def var v-credlim as deci init 0 no-undo.
def var v-path as char.

def new shared var v-iin as char init '' no-undo.

find first pkanketa where pkanketa.aaa = v-aaa and pkanketa.credtype = s-credtype no-lock no-error.
if not avail pkanketa then do:
   message "Анкета не найдена!" view-as alert-box question buttons ok.
   return.
end.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "credlim" no-lock no-error.
if avail pkanketh then v-credlim = deci(pkanketh.value1).

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
     and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "credhistbvuauto123" no-lock no-error.



if not avail pkanketh then do:
   /*message "Анкета Кредитная истории в БВУ не найдена!" view-as alert-box question buttons ok.*/
   message "Отчет ПКБ не найден!" view-as alert-box question buttons ok.
   return.
end.

def new shared temp-table wrk no-undo
   field dt as date
   field od as deci
   field prc as deci
   field koms as deci
   index idx is primary dt.
def new shared temp-table wrk2 no-undo
   field lon as char
   field days as int
   field counts as int
   index idx is primary days.

def temp-table temp_cs_data no-undo like pkanketh
    field dttype    as char
    field kritdispl as char
    field kritname  as char
    field kritspr   as char.

def var v-select as int init 0 no-undo.

/***********процедуры********************************************/
    function validVal returns logical (input v-val as char, input v-type as char).
        def var v-res as logi init yes.
        def var i as int.
        if v-type = "Целое число" then do:
           int(v-val) no-error.
           if error-status:error then v-res = no.
           do i = 1 to length(v-val) :
              if lookup(substr(v-val,i,1),'0,1,2,3,4,5,6,7,8,9,-') = 0 then v-res = no.
           end.
        end.
        if v-type = "Вещественное число" then do:
           deci(v-val) no-error.
           if error-status:error then v-res = no.
        end.
        if v-type = "Логический" then do:
           if v-val <> "да" and v-val <> "нет" then  v-res = no.
        end.

        return v-res.
    end function.

    function validF2 returns logical .
       def var v-res as logi init no.
       if trim(temp_cs_data.kritspr) = "" then v-res = yes. else do:
          if v-select = 0 then v-res = no. else v-res = yes.
       end.
       return v-res.
       /*displ temp_cs_data.kritspr v-select v-res. pause.*/
    end function.
/***********процедуры********************************************/

def var v-itog as char init 'Неприемлемый,Стабильный,Удовлетворительный,Неудовлетворительный,Нестабильный,Критический'.
def var v-ball as char init '-1,0,+1,+2,+3,+4'.


def button btnSave label "Сохранить".
/*def button btnAccept label "Контроль".*/
def button btnPrint label "Печать".
def button btnExit   label "Выход".

def QUERY q_cs_data  FOR temp_cs_data .
def browse b_cs_data query q_cs_data displ
        temp_cs_data.kritname     format "x(45)"  label 'Критерий'
        temp_cs_data.kritdispl  format "x(35)"  label 'Справочник'
        temp_cs_data.rating  format ">9-"  label 'Балл'
        with 20 down SEPARATORS title "Кредитный скоринг" overlay.
def frame fMain b_cs_data skip btnSave /*btnAccept*/ btnPrint btnExit  with centered overlay row 3 width 100 top-only.

def frame fProp
        temp_cs_data.kritname     format "x(50)"  label '  Критерий' skip
        temp_cs_data.kritdispl   format "x(40)" validate(validF2() ,'Выберите значение через F2') label        'Справочник' skip
        temp_cs_data.rating format ">9-" label        '      Балл' skip
        with side-labels centered row 8.

def temp-table temp_cs_catalog like codfr .
def QUERY q_cs_catalog  FOR temp_cs_catalog.
def browse b_cs_catalog query q_cs_catalog displ
        temp_cs_catalog.name[1]   format "x(50)"  label 'Значение'
        temp_cs_catalog.name[5]  format "x(3)"  label 'Балл'
        with 20 down SEPARATORS title "Справочник" overlay.
def frame fCatalog b_cs_catalog   with centered overlay row 3 width 85 top-only.

on help of temp_cs_data.kritdispl in frame fProp do:
    find first codfr where codfr.codfr = temp_cs_data.kritspr no-lock no-error.
    if avail codfr and trim(temp_cs_data.kritspr) <> "" then do:
        empty temp-table temp_cs_catalog.
        for each codfr where codfr.codfr = temp_cs_data.kritspr no-lock.
          create temp_cs_catalog.
          buffer-copy codfr to temp_cs_catalog.
        end.
        OPEN QUERY q_cs_catalog FOR EACH temp_cs_catalog.
        enable all with frame fCatalog.
        WAIT-FOR RETURN OF frame fCatalog FOCUS b_cs_catalog IN FRAME fCatalog.
        hide frame fCatalog.
        temp_cs_data.kritdispl = temp_cs_catalog.name[1].
        temp_cs_data.value1 = temp_cs_catalog.code.
        temp_cs_data.rating = int(temp_cs_catalog.name[5]).
        displ temp_cs_data.kritdispl temp_cs_data.rating with frame fProp.
        if trim(temp_cs_data.value1) <> "" then v-select = 1.
    end. else message "У критерия нет справочника! Введите значение" view-as alert-box question buttons ok.
end.

on "ENTER" of b_cs_data IN FRAME fMain do:
   v-select = 0.
   run procEdt.
end.

ON CHOOSE OF btnSave IN FRAME fMain do:
   find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
                      and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "IIN123" no-lock no-error.
   if avail pkanketh then do:
      message "Повторное сохраниние невозможно!" view-as alert-box question buttons ok.
   end. else  run procSave.
end.
/*ON CHOOSE OF btnAccept IN FRAME fMain do:
   run procAccept.
end.*/
ON CHOOSE OF btnPrint IN FRAME fMain do:
   run procPrint.
end.
ON CHOOSE OF btnExit IN FRAME fMain do:
   return.
end.

run procLoadData.
run procImportData.
run procCalcField.
run procCalcScore.
OPEN QUERY q_cs_data FOR EACH temp_cs_data.
enable all with frame fMain.
WAIT-FOR CHOOSE OF btnExit.

/***********процедуры********************************************/
    procedure Refresh:
       run procCalcField.
       run procCalcScore.
       browse b_cs_data:refresh().
    end.

    procedure procEdt:
       displ temp_cs_data.kritname with frame fProp.
       /*update  temp_cs_data.kritdispl temp_cs_data.rating with frame fProp.*/
       displ  temp_cs_data.kritdispl temp_cs_data.rating with frame fProp.
       hide frame fProp.
       run Refresh.
    end procedure.

    procedure procSave:
       output to 1.csv.
       for each temp_cs_data :
          export delimiter ";" temp_cs_data.
       end.
       for each temp_cs_data:
           find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
                                     and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = temp_cs_data.kritcod exclusive-lock no-error.
           if not avail pkanketh then  create pkanketh.

           buffer-copy temp_cs_data to pkanketh.
           if trim(temp_cs_data.kritspr) <> "" then pkanketh.value1 = temp_cs_data.value1. else pkanketh.value1 = temp_cs_data.kritdispl.
       end.
       find current pkanketa exclusive-lock no-error.
       find first temp_cs_data where temp_cs_data.kritcod = "itog123" no-error.
       if  avail pkanketa and avail temp_cs_data then do:
           if temp_cs_data.rating = -1 then pkanketa.sts = "100".
           if temp_cs_data.rating = 0  then pkanketa.sts = "120".

           find first prisv where prisv.rnn = pcstaff0.iin and prisv.rnn <> '' no-lock no-error.
           if avail prisv then do:
               message 'Физическое лицо связано с Банком особыми отношениями. Просим рассмотреть заявку в Нестандартном процессе!' view-as alert-box title 'ВНИМАНИЕ'.
               pkanketa.sts = "110".
               v-zag = 'Нестандартный процесс'.
               v-str = "Здравствуйте! Вам назначена задача по лицу, связанному с Банком особыми отношениями. Клиент: "
                     + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                     + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                     + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
               run mail2(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
           end.
           if pcstaff0.rez = no then do:
               message 'Физическое лицо является нерезидентом. Просим рассмотреть заявку в Нестандартном процессе' view-as alert-box title 'ВНИМАНИЕ'.
               pkanketa.sts = "110".
               v-zag = 'Нестандартный процесс'.
               v-str = "Здравствуйте! Вам назначена задача по лицу нерезиденту. Клиент: "
                     + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                     + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today)
                     + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Установление кредитного лимита".
               run mail2(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
           end.

           if temp_cs_data.rating > 0  then do:
              pkanketa.sts = "110".
              message "Просим рассмотреть заявку в Нестандартном процессе" view-as alert-box question buttons ok.
              run mail( g-ofc + "@fortebank.com", "bankadm@metrocombank.kz", "Кредитный скоринг", "Просим рассмотреть заявку в Нестандартном процессе", "1", "", "").
           end.
           pkanketa.rating = temp_cs_data.rating.
       end.



       run savelog('cs_data1', pkanketa.cif + " " + pkanketa.aaa + " " + string(pkanketa.ln) + " Данные сохранены").
       message "Данные сохранены!" view-as alert-box question buttons ok.
    end procedure.

    procedure procAccept:
       find current pkanketa exclusive-lock no-error.
       find first temp_cs_data where temp_cs_data.kritcod = "itog123" no-error.
       if  avail pkanketa and avail temp_cs_data then do:
           if temp_cs_data.rating = -1 then pkanketa.sts = "100".
           if temp_cs_data.rating = 0  then pkanketa.sts = "120".
           if temp_cs_data.rating > 0  then pkanketa.sts = "110".
           pkanketa.rating = temp_cs_data.rating.
       end.
       run savelog('cs_data1', pkanketa.cif + " " + pkanketa.aaa + " " + string(pkanketa.ln) + " Документ отконтролирован").
       message "Документ отконтролирован!" view-as alert-box question buttons ok.
    end.

    procedure procLoadData:
       /*for each pkkrit where pkkrit.credtype = s-credtype  no-lock:*/
       for each pkkrit where can-do(pkkrit.credtype,s-credtype) and pkkrit.priz = '1' no-lock:
          create temp_cs_data.
          assign
          temp_cs_data.rating = ?
          temp_cs_data.cif = pkanketa.cif
          temp_cs_data.bank = pkanketa.bank
          temp_cs_data.credtype = s-credtype
          temp_cs_data.ln = pkanketa.ln
          temp_cs_data.kritcod = pkkrit.kritcod
          temp_cs_data.dttype  = ""
          temp_cs_data.kritname = pkkrit.kritname
          temp_cs_data.kritspr = pkkrit.kritspr.
          find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype and pkanketh.ln = pkanketa.ln
                                    and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
          if avail pkanketh then do:
             buffer-copy pkanketh to temp_cs_data.
             find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = pkanketh.value1 no-lock no-error.
             if avail codfr then do:
                temp_cs_data.kritdispl = codfr.name[1].
             end. else do:
                temp_cs_data.kritdispl = pkanketh.value1.
             end.
          end.
       end.
    end procedure.

    procedure procImportData:
       def var v-cifcompany as char init ''.
       def var v-hdt as date init ?.
       def var v-salary as deci init ?.

       def var v-sum as deci init 0.

       def var v-bal7 as deci no-undo init 0.
       def var p-coun as integer no-undo.
       def var fdt as date no-undo.
       def var dayc1 as integer no-undo.

       find first cif where cif.cif = pkanketa.cif no-lock no-error.
       if avail cif then do:
          v-iin = cif.bin.
          find first pcstaff0 where pcstaff0.iin = cif.bin no-lock no-error.
          if avail pcstaff0 then assign v-cifcompany = pcstaff0.cifb v-hdt = pcstaff0.hdt v-salary = pcstaff0.salary.

          find first b-cif where b-cif.cif = v-cifcompany no-lock no-error.
          if avail b-cif then do:
             v-companyName = b-cif.prefix + " " + b-cif.name.
          end.
       end.

       for each temp_cs_data:
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "FIO123" then do:
             temp_cs_data.kritdispl = pkanketa.name.
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "IIN123" then do:
             find first cif where cif.cif = pkanketa.cif no-lock no-error.
             if avail cif then do:
                temp_cs_data.kritdispl = cif.bin.
             end.
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "regionin123" then do:
             find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.name[4] = pkanketa.bank no-lock no-error.
             if avail codfr then do:
                temp_cs_data.value1 = codfr.code.
                temp_cs_data.kritdispl = codfr.name[1].
                temp_cs_data.rating = int(codfr.name[5]).
             end.
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "companyyear123" then do:
             find first cif where cif.cif = v-cifcompany no-lock no-error.
             if avail cif then do:
                if (today - cif.expdt) / 30 < 6 then do:
                     find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "100" no-lock no-error.
                     if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                end.
                if (today - cif.expdt) / 30 >= 6 and (today - cif.expdt) / 30 < 12 then do:
                     find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "110" no-lock no-error.
                     if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                end.
                if (today - cif.expdt) / 30 >= 12 and (today - cif.expdt) / 30 < 36 then do:
                     find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "120" no-lock no-error.
                     if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                end.
                if (today - cif.expdt) / 30 >= 36 and (today - cif.expdt) / 30 < 60 then do:
                     find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "130" no-lock no-error.
                     if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                end.
                if (today - cif.expdt) / 30 >= 60 then do:
                     find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "140" no-lock no-error.
                     if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                end.
             end.
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "stazh123" then do:
             if (today - v-hdt) / 30 < 3 then do:
                  find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "100" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if (today - v-hdt) / 30 >= 3 and (today - v-hdt) / 30 < 12 then do:
                  find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "110" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if (today - v-hdt) / 30 >= 12 and (today - v-hdt) / 30 < 36 then do:
                  find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "120" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if (today - v-hdt) / 30 >= 36 and (today - v-hdt) / 30 < 60 then do:
                  find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "130" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if (today - v-hdt) / 30 >= 60 then do:
                  find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = "140" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "zp123" then do:
             if pkanketa.sumq = 0 then temp_cs_data.kritdispl = string(v-salary). else temp_cs_data.kritdispl = string(pkanketa.sumq).
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "credlim123" then do:
             if pkanketa.summa <> 0 then
                temp_cs_data.kritdispl = string(pkanketa.summa).
             else temp_cs_data.kritdispl = string(v-credlim).
          end.

          /*if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "credhist123" then do:
             find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = temp_cs_data.value1 no-lock no-error.
             if avail codfr then do:
                temp_cs_data.value1 = codfr.code.
                temp_cs_data.kritdispl = codfr.name[1].
                temp_cs_data.rating = int(codfr.name[5]).
             end.
          end.*/

          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "plattekob123" then do:
                empty temp-table wrk.

                {r-branch2.i &proc = "plattekob_txb"}

                for each wrk where month(wrk.dt) = month(today) and year(wrk.dt) = year(today) :
                    v-sum = v-sum + wrk.od + wrk.prc + wrk.koms.
                end.
                temp_cs_data.kritdispl = string(v-sum).
          end.

          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "credhist123" then do:
                def var valbvu as char init "100".
                def var val as char init "100".
                find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = s-credtype
                                  and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "credhistbvuauto123" no-lock no-error.
                if avail pkanketh then do: valbvu = pkanketh.value1. end.
                empty temp-table wrk2.

                {r-branch2.i &proc = "credhist_txb"}

                find first wrk2  use-index idx no-lock no-error.
                if not avail wrk2 then do:
                   find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = valbvu no-lock no-error.
                   if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                end.
                if avail wrk2 then do:
                    if wrk2.days >= 31 then do:
                       val = "150".
                    end.
                    if wrk2.days >= 25 and wrk2.days < 30 then do:
                       val = "140".
                    end.
                    if wrk2.days >= 20 and wrk2.days < 25 then do:
                       val = "130".
                    end.
                    if wrk2.days >= 15 and wrk2.days < 20 then do:
                       val = "120".
                    end.
                    if wrk2.days >= 1 and wrk2.days < 15 and wrk2.counts > 3 then do:
                       val = "110".
                    end.
                    if wrk2.days >= 0 and wrk2.days < 15 and wrk2.counts <= 3 then do:
                       val = "100".
                    end.

                    if int(val) < int(valbvu) then val = valbvu.
                    find first codfr where codfr.codfr = temp_cs_data.kritspr and codfr.code = val no-lock no-error.
                    if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).

                end.
          end.

       end.
    end procedure.

    procedure procCalcField:
        def var v-summa as deci init 0.
        def var v-plattekob as deci init 0.
        def var v-zp as deci init 0.
        for each temp_cs_data:
            if temp_cs_data.kritcod = "credlim123"   then  v-summa = deci(temp_cs_data.kritdispl).
            if temp_cs_data.kritcod = "plattekob123" then  v-plattekob = deci(temp_cs_data.kritdispl).
            if temp_cs_data.kritcod = "zp123"        then  v-zp = deci(temp_cs_data.kritdispl).
        end.
        for each temp_cs_data:
          if temp_cs_data.kritcod = "maxplatod123" then do:
             temp_cs_data.kritdispl = string(v-summa / 10).
          end.
          if temp_cs_data.kritcod = "maxplatproc123" then do:
             temp_cs_data.kritdispl = string(v-summa * 24 / 100 * 30 / 360).
          end.
          if temp_cs_data.kritcod = "dpkvzp123" then do:
             temp_cs_data.kritdispl = string(
                (v-summa / 10 + v-summa * 24 / 100 * 30 / 360 + v-plattekob) / v-zp * 100
             )  no-error.
             if deci(temp_cs_data.kritdispl) < 71 then temp_cs_data.rating = 0.
             if deci(temp_cs_data.kritdispl) >= 71 and deci(temp_cs_data.kritdispl) < 81 then temp_cs_data.rating = 1.
             if deci(temp_cs_data.kritdispl) >= 81 and deci(temp_cs_data.kritdispl) < 86 then temp_cs_data.rating = 2.
             if deci(temp_cs_data.kritdispl) >= 86 and deci(temp_cs_data.kritdispl) < 91 then temp_cs_data.rating = 3.
             if deci(temp_cs_data.kritdispl) >= 91 and deci(temp_cs_data.kritdispl) < 101 then temp_cs_data.rating = 4.
             if deci(temp_cs_data.kritdispl) >= 101 then temp_cs_data.rating = -1.
          end.
        end.
    end procedure.

    procedure procCalcScore:
        def var i as int.
        def var v-rating as int extent 5.
        def var v-itog as deci.
        for each temp_cs_data:
           if temp_cs_data.kritcod = "regionin123"    then v-rating[1] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "companyyear123" then v-rating[2] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "stazh123"       then v-rating[3] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "credhist123"    then v-rating[4] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "dpkvzp123"      then v-rating[5] = temp_cs_data.rating.
        end.
        v-itog = (v-rating[1] + v-rating[2] + v-rating[3] + v-rating[4]) / 4 * 0.3 + (v-rating[5] * 0.7).
        do i = 1 to 5:
           if v-rating[i] = -1 then v-itog = -1.
        end.
        find first temp_cs_data where temp_cs_data.kritcod = "itog123" no-error.
        if avail temp_cs_data then do:
           if int(v-itog) < 0 then      temp_cs_data.kritdispl = "Отказ".
           if int(v-itog) >= 0 and int(v-itog) < 1  then temp_cs_data.kritdispl = "Стабильный" .
           if int(v-itog) >= 1 and int(v-itog) < 2  then temp_cs_data.kritdispl = "Удовлетворительный".
           if int(v-itog) >= 2 and int(v-itog) < 3  then temp_cs_data.kritdispl = "Неудовлетворительный" .
           if int(v-itog) >= 3 and int(v-itog) < 4  then temp_cs_data.kritdispl = "Нестабильный" .
           if int(v-itog) >= 4 then temp_cs_data.kritdispl = "Критический".
           /*if v-itog < int(v-itog) then temp_cs_data.rating = int(v-itog) - 1. else*/ temp_cs_data.rating = int(v-itog).
        end.
    end procedure.

    def stream v-out.
    procedure procPrint:
        def var v-ofile as char.
        def var v-ifile as char.
        def var v-str as char.
        message "Ждите...". pause 0.
        /*input through value("cpy -put /data/export/cs_print.png c:/tmp").*/

        v-ofile = "ofile.htm" .
        /*v-ifile = "/data/export/cs_print.htm".*/
        v-ifile = "/data/docs/cs_print.htm".
        output stream v-out to value(v-ofile).
        input from value(v-ifile).

        repeat:
           import unformatted v-str.
           v-str = trim(v-str).
           /*message v-str. pause.*/
           l:
           repeat:
              if v-str matches "*org123*" then do:
                 v-str = replace (v-str, "org123", v-companyName).
                 next.
              end.
              if v-str matches "*ddmmyyyy*" then do:
                 v-str = replace (v-str, "ddmmyyyy", string(today)).
                 next.
              end.

              if v-str matches "*dpkvzp123bal*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "dpkvzp123".
                 v-str = replace (v-str, "dpkvzp123bal", string(temp_cs_data.rating)).
                 next.
              end.
              if v-str matches "*dpkvzp123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "dpkvzp123".
                 v-str = replace (v-str, "dpkvzp123", string(temp_cs_data.kritdispl) + "%").
                 next.
              end.

              for each temp_cs_data:
                 if v-str matches "*" + temp_cs_data.kritcod + "bal" + "*" then do:
                    v-str = replace (v-str, temp_cs_data.kritcod + "bal", string(temp_cs_data.rating)).
                    next l.
                 end.
                 if v-str matches "*" + temp_cs_data.kritcod + "*" then do:
                    v-str = replace (v-str, temp_cs_data.kritcod, temp_cs_data.kritdispl).
                    /*message temp_cs_data.kritcod ' ' temp_cs_data.kritdispl. pause.*/
                    next l.
                 end.
              end.
              leave.
           end.

           put stream v-out unformatted v-str skip.
        end.

        input close.
        output stream v-out close.
        unix silent cptunkoi value(v-ofile) winword.
    end procedure.