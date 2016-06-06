/* LCvalid.i
 * MODULE
        Trade Finance
 * DESCRIPTION
        Функции валидации
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
        09/09/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        20/09/2010 galina - вводим только целые значения для параметров типа integer
        23/09/2010 galina - поменяла формат ввода поля 39:A (Percent Credit Amount Tolerance) и добавила фунцию проверки
        24/09/2010 galina - добавила процедуру validRref
        25/11/2010 galina - добавила новый критерий AdvThOpt
        10/02/2011 id00810 - изменила обработку критериев AccIns, BenIns
        04/03/2011 id00810 - добавила процедуру validbin, изменила значения в validKBE
        29/09/2011 id00810 - добавила процедуру validLimNum
*/

function validkrtype returns logi (input p-dataCode as char, input p-value as char).
    def var res as logi no-undo init yes.
    def var v-dt as date no-undo.
    def var v-i as integer no-undo.
    def var v-r as decimal no-undo.
    def var v-l as logical no-undo.

    def var v-logs as char init "yes,no,y,n,да,нет,д,н,0,1".
    find first LCkrit where LCkrit.dataCode = p-dataCode no-lock no-error.
    if avail LCkrit then do:
        case LCkrit.dataType:
            when 'i' then do:
                v-i = integer(p-value) no-error.
                if error-status:error then res = no.
                if res then do:
                    v-r = round(deci(p-value),2).
                    if v-r <> v-i then  res = no.
                end.
            end.
            when 'r' then do:
                v-r = deci(p-value) no-error.
                if error-status:error then res = no.
            end.
            when 'd' then do:
                v-dt = date(p-value) no-error.
                if error-status:error then res = no.
            end.
            when 'l' then do:
                if lookup(p-value, v-logs) = 0 then res = no.
            end.
        end case.
    end.
    return res.
end function.

function validh returns logi (input p-dataCode as char, input p-value as char, output p-errMsg as char).
    def var res as logi no-undo init yes.
    find first LCkrit where LCkrit.dataCode = p-dataCode no-lock no-error.
    if avail LCkrit then do:
        if p-value <> '' then do:
            if trim(LCkrit.dataSpr) <> '' then do:
                find first codfr where codfr.codfr = trim(LCkrit.dataSpr) and codfr.code = p-value no-lock no-error.
                if not avail codfr then assign res = no p-errMsg = "There is no such a value in the reference!".
            end.
            else do:
                if p-dataCode = 'AdvThrou' then do:
                    find first b-LCotherD where b-LCotherD.LC = s-lc and b-LCotherD.kritcode = 'AdvThOpt' no-lock no-error.
                    if avail b-LCotherD and b-LCotherD.value1 = 'A' then do:
                        find first swibic where swibic.bic = p-value no-lock no-error.
                        if not avail swibic then assign res = no p-errMsg = "There is no such a value in the reference!".
                    end.
                end.
                if p-dataCode = 'AccIns' then do:
                    find first b-LCpay where b-LCpay.LC = s-lc and b-LCpay.kritcode = 'AccInsOp' no-lock no-error.
                    if avail b-LCpay and b-LCpay.value1 = 'A' then do:
                         find first swibic where swibic.bic = p-value no-lock no-error.
                         if not avail swibic then assign res = no p-errMsg = "There is no such a value in the reference!".
                    end.
                    else do:
                        res = validkrtype(p-dataCode,p-value).
                        if not res then p-errMsg = "The incorrect value has been entered!".
                    end.
                end.
                if p-dataCode = 'BenIns' then do:
                    find first b-LCpay where b-LCpay.LC = s-lc and b-LCpay.kritcode = 'BenInsOp' no-lock no-error.
                    if avail b-LCpay and b-LCpay.value1 = 'A' then do:
                         if v-crc = 1  then do:
                            find first bankl where bankl.bank = p-value no-lock no-error.
                            if not avail bankl then assign res = no p-errMsg = "There is no such a value in the reference!".
                          end.
                         else do:
                            find first swibic where swibic.bic = p-value no-lock no-error.
                            if not avail swibic then assign res = no p-errMsg = "There is no such a value in the reference!".
                         end.
                    end.
                    else do:
                        res = validkrtype(p-dataCode,p-value).
                        if not res then p-errMsg = "The incorrect value has been entered!".
                    end.
                end.
                if lookup(p-dataCode,'AdvBank,AvlWith,Drawee,InsTo756,RCor,Intermid,ReimBnk') > 0 then do:
                    find first swibic where swibic.bic = p-value no-lock no-error.
                    if not avail swibic then assign res = no p-errMsg = "There is no such a value in the reference!".
                end.
                if lookup(p-dataCode,'InsTo202,SCor756') > 0 then do:
                    find first LCswtacc where LCswtacc.swift = p-value no-lock no-error.
                    if not avail LCswtacc then assign res = no p-errMsg = "There is no such a value in the reference!".
                end.
                if lookup(p-dataCode,'SCor202') > 0 then do:
                    find first LCswtacc where LCswtacc.accout = p-value no-lock no-error.
                    if not avail LCswtacc then assign res = no p-errMsg = "There is no such a value in the reference!".
                    /*if avail LCswtacc then p-errMsg = "valid!".*/
                end.
                if lookup(p-dataCode,'AdvBank,AvlWith,Drawee,ReimBnk,InsTo756,InsTo202,SCor756,SCor202,RCor,Intermid,AccIns,BenIns,AdvThrou,ReimBnk') = 0 then do:
                    if trim(LCkrit.valProc) <> '' then do:
                        run value(trim(LCkrit.valProc)) (p-value,output res, output p-errMsg).
                    end.
                    else do:
                        res = validkrtype(p-dataCode,p-value).
                        if not res then p-errMsg = "The incorrect value has been entered!".
                    end.
                end.
            end.
        end.
    end.
    return res.
end function.


{chkaaa20.i}

procedure validaaa.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.

   /*if trim(p-value) = '' then do:

        assign p-res = no p-errMsg = "Enter account number!".
        return.
   end.*/

       find first aaa where aaa.aaa = p-value no-lock no-error.
       if not avail aaa then do:
           assign p-res = no p-errMsg = "Account is not found!".
           return.
       end.

       if avail aaa and aaa.cif <> v-cif then do:
           assign p-res = no p-errMsg = "This account belongs to another customer!".
           return.
       end.

       if chkaaa20(p-value) = no then do:
           assign p-res = no p-errMsg = "The account number is incorrect!".
           return.
       end.


   p-res = yes.

end procedure.


procedure validPeramt.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.

   def var v-i as integer no-undo.
   def var v-r as decimal no-undo.
   def var i as integer no-undo.

   /*if trim(p-value) = '' then do:
        assign p-res = no p-errMsg = "Enter the value!".
        return.
   end.*/
   if num-entries(p-value,'/') <> 2 then do:
       assign p-res = no p-errMsg = "The incorrect value has been entered!".
       return.
   end.

   v-i = 0.
   v-r = 0.
   do i = 1 to 2:
       v-i = integer(entry(i,p-value,'/')) no-error.
       if error-status:error then do:
           assign p-res = no p-errMsg = "The incorrect value has been entered!".
           return.
       end.
       else do:
           v-r = round(deci(entry(i,p-value,'/')),2).
           if v-r <> v-i then do:
               p-res = no.
               if i = 1 then p-errMsg = "The first value must be integer!".
               if i = 2 then p-errMsg = "The second value must be integer!".
               return.
           end.
       end.
   end.
   if int(entry(1,p-value,'/')) >= 100 or int(entry(2,p-value,'/')) >= 100 or int(entry(1,p-value,'/')) <= 0 or int(entry(2,p-value,'/')) <= 0 then do:
        p-res = no.
        if int(entry(1,p-value,'/')) >= 100 or int(entry(1,p-value,'/')) <= 0 then p-errMsg = "The first value must be less than 100 and greater than 0!".
        if int(entry(2,p-value,'/')) >= 100 or int(entry(2,p-value,'/')) <= 0 then p-errMsg = "The second value must be less than 100 and greater than 0!".
        return.
   end.
   p-res = yes.
end procedure.


procedure validRref.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.

/*   if trim(p-value) = '' then do:
        assign p-res = no p-errMsg = "Enter the value!".
        return.
   end.*/

   if p-value begins '/' then do:
       assign p-res = no p-errMsg = "The incorrect value has been entered!".
       return.
   end.
   if substr(p-value,length(p-value), 1) = '/' then do:
       assign p-res = no p-errMsg = "The incorrect value has been entered!".
       return.
   end.

   p-res = yes.
end procedure.

procedure validDecAmt.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.
   def var v-lcsum as deci.
    find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
    if avail lch and lch.value1 <> '' then do:
        v-lcsum = 0.
        v-lcsum = deci(lch.value1).
        /*учитываем суммы amendment*/
        for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
            find first jh where jh.jh = lcamendres.jh no-lock no-error.
            if not avail jh then next.

            if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsum = v-lcsum + lcamendres.amt.
            if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsum = v-lcsum - lcamendres.amt.
        end.
        /*учитываем суммы payment*/
        for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or  lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
            find first jh where jh.jh = lcpayres.jh no-lock no-error.
            if avail jh then v-lcsum = v-lcsum - lcpayres.amt.
        end.
        /*учитываем суммы event */
        for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24) and lceventres.jh > 0 no-lock:
            find first jh where jh.jh = lceventres.jh no-lock no-error.
            if avail jh then v-lcsum = v-lcsum - lceventres.amt.
        end.

        if deci(p-value) > v-lcsum then do:
           assign p-res = no p-errMsg = "The value in field Decrease of Amount must be =< " + trim(string(v-lcsum,'>>>>>>>>>9.99')) + "!".
           return.
        end.
    end.
    p-res = yes.

end.

procedure validPAmt.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.
   def var v-lcsum as deci.
   def var v-per   as int.

    find first lch where lch.lc = s-lc and lch.kritcode = 'Amount' no-lock no-error.
    if avail lch and lch.value1 <> '' then do:
        v-lcsum = 0.
        v-lcsum = deci(lch.value1).
        find first lch where lch.lc = lc.lc and lch.kritcode = 'peramt' no-lock no-error.
        if avail lch and lch.value1 ne '' then do:
            v-per = int(entry(1,lch.value1, '/')).
            if v-per > 0 then v-lcsum = v-lcsum + (v-lcsum * (v-per / 100)).
        end.

        /*учитываем суммы amendment*/
        for each lcamendres where lcamendres.lc = s-lc and (lcamendres.levC = 23 or lcamendres.levD = 23 or lcamendres.levC = 24 or lcamendres.levD = 24) and lcamendres.jh > 0 no-lock:
            find first jh where jh.jh = lcamendres.jh no-lock no-error.
            if not avail jh then next.

            if lcamendres.levD = 23 or lcamendres.levD = 24 then v-lcsum = v-lcsum + lcamendres.amt.
            if lcamendres.levC = 23 or lcamendres.levC = 24 then v-lcsum = v-lcsum - lcamendres.amt.
        end.
        /*учитываем суммы payment*/
        for each lcpayres where lcpayres.lc = s-lc and (lcpayres.levC = 23 or  lcpayres.levC = 24) and lcpayres.jh > 0 no-lock:
            find first jh where jh.jh = lcpayres.jh no-lock no-error.
            if avail jh then v-lcsum = v-lcsum - lcpayres.amt.
        end.
        /*учитываем суммы event */
        for each lceventres where lceventres.lc = s-lc and (lceventres.levC = 23 or lceventres.levC = 24) and lceventres.jh > 0 no-lock:
            find first jh where jh.jh = lceventres.jh no-lock no-error.
            if avail jh then v-lcsum = v-lcsum - lceventres.amt.
        end.

       if deci(p-value) > v-lcsum then do:
           assign p-res = no p-errMsg = "The value in field Payment Amount must be =< " + trim(string(v-lcsum,'>>>>>>>>>9.99')) + "!".
           return.
       end.
    end.
    p-res = yes.

end.

procedure validLimNum.
   def input  parameter p-value  as char no-undo.
   def output parameter p-res    as logi no-undo.
   def output parameter p-errMsg as char no-undo.

   def var v-lim   as deci no-undo.

       find first lclimit where lclimit.bank = s-ourbank and lclimit.cif = v-cif and lclimit.number = int(p-value) no-lock no-error.
       if not avail lclimit then do:
           assign p-res = no p-errMsg = "Limit is not found!".
           return.
       end.

       if avail lclimit and lclimit.sts <> 'FIN' then do:
           assign p-res = no p-errMsg = "The status of limit is not FIN!".
           return.
       end.

       for each lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.jh > 0 no-lock.
            if substr(lclimitres.dacc,1,2) = '61' then v-lim = v-lim + lclimitres.amt.
            else v-lim = v-lim - lclimitres.amt.
        end.
        if v-lim = 0 then do:
            assign p-res = no p-errMsg = "The Rest of limit = 0!".
            return.
        end.

   p-res = yes.
end.

procedure validKBE.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.
   if p-value <> '17' and p-value <> '27' then do:
       assign p-res = no p-errMsg = "The value in field KBE must be 17 or 27!".
       return.
   end.
    p-res = yes.
end.


procedure validiik.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.
   if p-value begins 'KZ' then do:
       if chkaaa20(p-value) = no then do:
           assign p-res = no p-errMsg = "The account number is incorrect!".
           return.
       end.
   end.
   p-res = yes.

end procedure.

procedure validVdate.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.

/*   if trim(p-value) = '' then do:
        assign p-res = no p-errMsg = "Enter the value!".
        return.
   end.*/

   if date(p-value) < g-today then do:
       assign p-res = no p-errMsg = "The Value Date must be >= Operation date!".
       return.
   end.

   p-res = yes.
end procedure.

{chbin.i}
{comm-rnn.i}
{chk12_innbin.i}

procedure validbin.
   def input parameter p-value as char no-undo.
   def output parameter p-res as logi no-undo.
   def output parameter p-errMsg as char no-undo.

   p-res = yes.
   if v-bin = no and comm-rnn (p-value) then assign p-res = no p-errMsg = "Incorrect RNN!".
   else if v-bin and not chk12_innbin(p-value) then  assign p-res = no p-errMsg = "'Incorrect RNN/BIN!".

   if not p-res then return.

end procedure.
