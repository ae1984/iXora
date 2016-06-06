/* kfmAMLAdd2.p
 * MODULE
        Фин. мониторинг - Взаимодействие с AML
 * DESCRIPTION
        Сервис для возврата доп. инфо по клиенту в AML
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
        29/06/2010 madiyar
 * BASES
        BANK COMM TXB
 * CHANGES
        30/06/2010 madiyar - перекомпиляция
        06/10/2010 madiyar - parseAddressBank
        24/09/2013 yerganat - tz1839, добавил org_form.i
*/

def input parameter p-clientType as char no-undo.
def input parameter p-clientId as char no-undo.
def output parameter p-res as integer no-undo.

def shared temp-table t-part no-undo
  field pId as integer
  field pName as char
  field pValue as char
  field pType as char
  index idx is primary pId.

def shared temp-table t-founder no-undo
  field pId as integer
  field pName as char
  field pValue as char
  field pType as char
  index idx is primary pId.

{org_form.i}
def var i as integer no-undo.
def var v-str as char no-undo.
def var v-str2 as char no-undo.
def var v-dt as date no-undo.
def var v-country_cod as char no-undo.

def var memberKind as char no-undo.
def var memberRole as char no-undo.
def var memberResBool as char no-undo.
def var memberResCountryCode as char no-undo.
def var memberType as char no-undo.
def var memberForeignCode as char no-undo.
def var memberForeignExtra as char no-undo.
def var memberBankCode as char no-undo.
def var memberBankName as char no-undo.
def var memberBankAccount as char no-undo.
def var memberBankAddress as char no-undo.
def var memberTaxCode as char no-undo.
def var memberOKPO as char no-undo.
def var memberOKED as char no-undo.
def var memberMainCode as char no-undo.
def var memberPhone as char no-undo.
def var memberEmail as char no-undo.

def var memberRegCountryCode as char no-undo.
def var memberRegArea as char no-undo.
def var memberRegRegion as char no-undo.
def var memberRegCity as char no-undo.
def var memberRegStreet as char no-undo.
def var memberRegHouse as char no-undo.
def var memberRegOffice as char no-undo.
def var memberRegPostCode as char no-undo.

def var memberSeatCountryCode as char no-undo.
def var memberSeatArea as char no-undo.
def var memberSeatSeation as char no-undo.
def var memberSeatCity as char no-undo.
def var memberSeatStreet as char no-undo.
def var memberSeatHouse as char no-undo.
def var memberSeatOffice as char no-undo.
def var memberSeatPostCode as char no-undo.

def var memberComments as char no-undo.
def var memberUrName as char no-undo.
def var memberUrFirstHeadName as char no-undo.
def var memberDirfirstname as char no-undo.
def var memberDirlastname as char no-undo.
def var memberDirmiddlename as char no-undo.
def var memberOrgform as char no-undo.
def var memberAcFirstName as char no-undo.
def var memberAcSecondName as char no-undo.
def var memberAcMiddleName as char no-undo.
def var memberAcDocTypeCode as char no-undo.
def var memberAcDocNumber as char no-undo.
def var memberAcDocSeries as char no-undo.
def var memberAcDocWhom as char no-undo.
def var memberAcDocIssueDate as char no-undo.
def var memberAcBirthDate as char no-undo.
def var memberAcBirthPlace as char no-undo.
def var memberFoundersCount as integer no-undo.

def var founderMainCode as char no-undo.

def var founderRegCountryCode as char no-undo.
def var founderRegArea as char no-undo.
def var founderRegRegion as char no-undo.
def var founderRegCity as char no-undo.
def var founderRegStreet as char no-undo.
def var founderRegHouse as char no-undo.
def var founderRegOffice as char no-undo.
def var founderRegPostCode as char no-undo.

def var founderSeatCountryCode as char no-undo.
def var founderSeatArea as char no-undo.
def var founderSeatSeation as char no-undo.
def var founderSeatCity as char no-undo.
def var founderSeatStreet as char no-undo.
def var founderSeatHouse as char no-undo.
def var founderSeatOffice as char no-undo.
def var founderSeatPostCode as char no-undo.

def var founderUrName as char no-undo.
def var founderUrResidenceBool as char no-undo.
def var founderUrResidenceCountryCode as char no-undo.
def var founderUrRegWhom as char no-undo.
def var founderUrRegNumber as char no-undo.
def var founderUrRegDate as char no-undo.
def var founderUrTaxCode as char no-undo.
def var founderAcFirstName as char no-undo.
def var founderAcSecondName as char no-undo.
def var founderAcMiddleName as char no-undo.
def var founderAcBirthDate as char no-undo.
def var founderAcRegNumber as char no-undo.
def var founderAcRegSeries as char no-undo.
def var founderAcRegWhom as char no-undo.
def var founderAcRegDate as char no-undo.

def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

p-res = 0.

function stripXMLTags returns char (input str as char).
    def var res as char no-undo.
    def var ii as integer no-undo.
    do ii = 1 to length(str):
        if asc(substring(str,ii,1)) <> 22 then res = res + substring(str,ii,1).
    end.
    res = replace(res,'<','').
    res = replace(res,'>','').
    res = replace(res,'&','').
    res = replace(res,'№','N').
    res = replace(res,'«','"').
    res = replace(res,'»','"').
    return res.
end function.

procedure createPParam:
    def input parameter vName as char no-undo.
    def input parameter vValue as char no-undo.
    def input parameter vType as char no-undo.

    def var vId as integer no-undo.

    find last t-part no-lock no-error.
    if avail t-part then vId = t-part.pId + 1.
    else vId = 1.

    if vType = 'c' then vValue = stripXMLTags(vValue).

    create t-part.
    assign t-part.pId = vId
           t-part.pName = vName
           t-part.pValue = vValue
           t-part.pType = vType.
end procedure.

procedure createFParam:
    def input parameter vName as char no-undo.
    def input parameter vValue as char no-undo.
    def input parameter vType as char no-undo.

    def var vId as integer no-undo.

    find last t-founder no-lock no-error.
    if avail t-founder then vId = t-founder.pId + 1.
    else vId = 1.

    if vType = 'c' then vValue = stripXMLTags(vValue).

    create t-founder.
    assign t-founder.pId = vId
           t-founder.pName = vName
           t-founder.pValue = vValue
           t-founder.pType = vType.
end procedure.

procedure parseAddress.
    def input parameter p-fm as char no-undo.
    def input parameter p-suffix as char no-undo.
    def input parameter p-dataValue as char no-undo.

    def var v-country2 as char no-undo init ''.
    def var v-country_cod as char no-undo init '0'.
    def var v-region as char no-undo init ''.
    def var v-city as char no-undo init ''.
    def var v-street as char no-undo init ''.
    def var v-house as char no-undo init ''.
    def var v-office as char no-undo init ''.
    def var v-index  as char no-undo init '0'.

    if num-entries(p-dataValue) = 7 then do:
        v-country2 = entry(1,p-dataValue).
        if num-entries(v-country2,"(") = 2 then v-country_cod = substr(entry(2,entry(1,p-dataValue),"("),1,2).
        assign v-region = entry(2,p-dataValue)
               v-city = entry(3,p-dataValue)
               v-street = entry(4,p-dataValue)
               v-house = entry(5,p-dataValue)
               v-office = entry(6,p-dataValue)
               v-index = entry(7,p-dataValue).

        find first code-st where code-st.code = v-country_cod no-lock no-error.
        if avail code-st then v-country_cod = code-st.cod-ch.

        if p-fm begins "founder" then do:
            run createFParam(p-fm + "CountryCode" + p-suffix, v-country_cod, 'c').
            run createFParam(p-fm + "Area" + p-suffix, v-region, 'c').
            run createFParam(p-fm + "Region" + p-suffix, '', 'c').
            run createFParam(p-fm + "City" + p-suffix, v-city, 'c').
            run createFParam(p-fm + "Street" + p-suffix, v-street, 'c').
            run createFParam(p-fm + "House" + p-suffix, v-house, 'c').
            run createFParam(p-fm + "Office" + p-suffix, v-office, 'c').
            run createFParam(p-fm + "PostCode" + p-suffix, v-index, 'c').
        end.
        else if p-fm begins "member" then do:
            run createPParam(p-fm + "CountryCode" + p-suffix, v-country_cod, 'c').
            run createPParam(p-fm + "Area" + p-suffix, v-region, 'c').
            run createPParam(p-fm + "Region" + p-suffix, '', 'c').
            run createPParam(p-fm + "City" + p-suffix, v-city, 'c').
            run createPParam(p-fm + "Street" + p-suffix, v-street, 'c').
            run createPParam(p-fm + "House" + p-suffix, v-house, 'c').
            run createPParam(p-fm + "Office" + p-suffix, v-office, 'c').
            run createPParam(p-fm + "PostCode" + p-suffix, v-index, 'c').
        end.

    end.
end procedure. /* parseAddress */

procedure parseAddressBank.
    def input parameter p-fm as char no-undo.
    def input parameter p-suffix as char no-undo.
    def input parameter p-dataValue as char no-undo.

    def var v-country2 as char no-undo init ''.
    def var v-country_cod as char no-undo init '0'.
    def var v-region as char no-undo init ''.
    def var v-city as char no-undo init ''.
    def var v-street as char no-undo init ''.
    def var v-house as char no-undo init ''.
    def var v-office as char no-undo init ''.
    def var v-index  as char no-undo init '0'.

    v-country_cod = "KZ".
    find first code-st where code-st.code = v-country_cod no-lock no-error.
    if avail code-st then v-country_cod = code-st.cod-ch.

    case s-ourbank:
        when "txb00" then v-region = 'Алматинская обл.'.
        when "txb01" then v-region = 'Актюбинская обл.'.
        when "txb02" then v-region = 'Костанайская обл.'.
        when "txb03" then v-region = 'Жамбылская обл.'.
        when "txb04" then v-region = 'Западно-Казахстанская обл.'.
        when "txb05" then v-region = 'Карагандинская обл.'.
        when "txb06" then v-region = 'Семипалатинская обл.'.
        when "txb07" then v-region = 'Акмолинская обл.'.
        when "txb08" then v-region = 'Акмолинская обл.'.
        when "txb09" then v-region = 'Павлодарская обл.'.
        when "txb10" then v-region = 'Северо-Казахстанская обл.'.
        when "txb11" then v-region = 'Атырауская обл.'.
        when "txb12" then v-region = 'Мангистауская обл.'.
        when "txb13" then v-region = 'Карагандинская обл.'.
        when "txb14" then v-region = 'Восточно-Казахстанская обл.'.
        when "txb15" then v-region = 'Южно-Казахстанская обл.'.
        when "txb16" then v-region = 'Алматинская обл.'.
    end case.

    do i = 1 to num-entries(p-dataValue):
        if i = 1 then v-city = entry(i,p-dataValue).
        else
        if i = 2 then v-street = entry(i,p-dataValue).
        else
        if i = 3 then v-house = entry(i,p-dataValue).
        else
        if i = 4 then v-office = entry(i,p-dataValue).
    end.

    if p-fm begins "founder" then do:
        run createFParam(p-fm + "CountryCode" + p-suffix, v-country_cod, 'c').
        run createFParam(p-fm + "Area" + p-suffix, v-region, 'c').
        run createFParam(p-fm + "Region" + p-suffix, '', 'c').
        run createFParam(p-fm + "City" + p-suffix, v-city, 'c').
        run createFParam(p-fm + "Street" + p-suffix, v-street, 'c').
        run createFParam(p-fm + "House" + p-suffix, v-house, 'c').
        run createFParam(p-fm + "Office" + p-suffix, v-office, 'c').
        run createFParam(p-fm + "PostCode" + p-suffix, v-index, 'c').
    end.
    else if p-fm begins "member" then do:
        run createPParam(p-fm + "CountryCode" + p-suffix, v-country_cod, 'c').
        run createPParam(p-fm + "Area" + p-suffix, v-region, 'c').
        run createPParam(p-fm + "Region" + p-suffix, '', 'c').
        run createPParam(p-fm + "City" + p-suffix, v-city, 'c').
        run createPParam(p-fm + "Street" + p-suffix, v-street, 'c').
        run createPParam(p-fm + "House" + p-suffix, v-house, 'c').
        run createPParam(p-fm + "Office" + p-suffix, v-office, 'c').
        run createPParam(p-fm + "PostCode" + p-suffix, v-index, 'c').
    end.

end procedure. /* parseAddressBank */


case p-clientType:
    when "bank" then do:

        p-res = 1.

        memberKind = '5'.
        run createPParam("memberKind",memberKind,'i').

        memberRole = '1'. /* самостоятельно */
        run createPParam("memberRole",memberRole,'i').

        assign memberResBool = '1' memberResCountryCode = '398'.
        run createPParam("memberResBool",memberResBool,'i').
        run createPParam("memberResCountryCode",memberResCountryCode,'c').

        memberType = '1'.
        run createPParam("memberType",memberType,'i')   .

        find first txb.cmp no-lock no-error.
        if avail txb.cmp then do:
            memberTaxCode = txb.cmp.addr[2].
            run createPParam("memberTaxCode",memberTaxCode,'c').
            memberOKPO = txb.cmp.addr[3].
            run createPParam("memberOKPO",memberOKPO,'c').
        end.

        memberOKED = '65'.
        run createPParam("memberOKED",memberOKED,'c').

        memberMainCode = ''.
        find first txb.sysc where txb.sysc.sysc = "bnkbin" no-lock no-error.
        if avail txb.sysc then memberMainCode = txb.sysc.chval.
        run createPParam("memberMainCode",memberMainCode,'c').

        memberPhone = txb.cmp.tel.
        run createPParam("memberPhone",memberPhone,'c').

        memberEmail = ''.
        find first txb.sysc where txb.sysc.sysc = "bnkadr" no-lock no-error.
        if avail txb.sysc then do:
            memberEmail = entry(5, txb.sysc.chval, "|") no-error.
            if memberEmail = ? then memberEmail = ''.
            /* v-addr = entry(1, txb.sysc.chval, "|"). -- почтовый индекс -- */
        end.
        run createPParam("memberEmail",memberEmail,'c').

        if avail txb.cmp then do:
            run parseAddressBank("memberReg", '', txb.cmp.addr[1]).
            run parseAddressBank("memberSeat", '', txb.cmp.addr[1]).
        end.

        if avail txb.cmp then do:
            memberUrName = trim(txb.cmp.name).
            run createPParam("memberUrName",memberUrName,'c').
        end.

        memberUrFirstHeadName = ''.
        find first txb.codfr where txb.codfr.codfr = 'DKPODP' and txb.codfr.code = '1' no-lock no-error.
        if avail txb.codfr then memberUrFirstHeadName = txb.codfr.name[1].
        run createPParam("memberUrFirstHeadName",memberUrFirstHeadName,'c').

        if num-entries(memberUrFirstHeadName,' ') > 0 then do:
           memberDirlastname = entry(1,memberUrFirstHeadName,' ').
           if num-entries(memberUrFirstHeadName,' ') > 1 then do:
              memberDirfirstname = entry(2,memberUrFirstHeadName,' ').
              if num-entries(memberUrFirstHeadName,' ') > 2 then
                 memberDirmiddlename = entry(3,memberUrFirstHeadName,' ').
           end.
        end.

        run createPParam("memberDirlastname",memberDirlastname,'c').
        run createPParam("memberDirfirstname",memberDirfirstname,'c').
        run createPParam("memberDirmiddlename",memberDirmiddlename,'c').

        memberFoundersCount = 0.
        run createPParam("memberFoundersCount",string(memberFoundersCount),'i').

        memberOrgform = '28'. /*из org_form.i*/
        run createPParam("memberOrgform", memberOrgform ,'c').


    end.
    when "cif" then do:
        find first txb.cif where txb.cif.cif = p-clientId no-lock no-error.
        if avail txb.cif then do:

            p-res = 1.

            memberKind = '5'.
            run createPParam("memberKind",memberKind,'i').

            memberRole = '1'. /* самостоятельно */
            run createPParam("memberRole",memberRole,'i').

            if txb.cif.geo = '021' then assign memberResBool = '1' memberResCountryCode = '398'.
            else do:
                memberResBool = '0'.
                memberResCountryCode = '0'.
                if num-entries(txb.cif.addr[1]) = 7 then do:
                    v-str = entry(1,txb.cif.addr[1]).
                    if num-entries(v-str,'(') = 2 then v-str2 = substr(entry(2,v-str,'('),1,2).
                    find first code-st where code-st.code = v-str2 no-lock no-error.
                    if avail code-st then memberResCountryCode = code-st.cod-ch.
                end.
            end.
            run createPParam("memberResBool",memberResBool,'i').
            run createPParam("memberResCountryCode",memberResCountryCode,'c').

            if txb.cif.type = 'B' then do:
                if txb.cif.cgr <> 403 then memberType = '1'.
                if txb.cif.cgr = 403 then memberType = '3'.
            end.
            else memberType = '2'.
            run createPParam("memberType",memberType,'i').

            if memberType = '2' or memberType = '3' then do:
                memberForeignCode = '0'.
                find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "publicf" use-index dcod no-lock no-error.
                if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then memberForeignCode = sub-cod.ccode.
                run createPParam("memberForeignCode",memberForeignCode,'i').
                run createPParam("memberForeignExtra",'','c').
            end.

            /*
            run createPParam("memberBankCode","",'c').
            run createPParam("memberBankName","",'c').
            run createPParam("memberBankAccount","",'c').
            run createPParam("memberBankAddress","",'c').
            */

            memberTaxCode = txb.cif.jss.
            run createPParam("memberTaxCode",memberTaxCode,'c').
            memberOKPO = txb.cif.ssn.
            run createPParam("memberOKPO",memberOKPO,'c').

            memberOKED = ''.
            find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" use-index dcod no-lock no-error.
            if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then memberOKED = txb.sub-cod.ccode.
            run createPParam("memberOKED",memberOKED,'c').

            memberMainCode = txb.cif.bin.
            run createPParam("memberMainCode",memberMainCode,'c').

            memberPhone = txb.cif.tel.
            run createPParam("memberPhone",memberPhone,'c').

            find first txb.cif-mail where txb.cif-mail.cif = txb.cif.cif no-lock no-error.
            if avail txb.cif-mail then memberEmail = txb.cif-mail.mail.
            run createPParam("memberEmail",memberEmail,'c').

            run parseAddress("memberReg", '', txb.cif.addr[1]).
            run parseAddress("memberSeat", '', txb.cif.addr[2]).

            if memberType = '1' then do:
                memberUrName = trim(txb.cif.prefix) + ' ' + trim(txb.cif.name).
                run createPParam("memberUrName",memberUrName,'c').
                memberUrFirstHeadName = ''.
                find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnchf" use-index dcod no-lock no-error.
                if avail txb.sub-cod and txb.sub-cod.ccode <> 'msc' then memberUrFirstHeadName = txb.sub-cod.rcode.
                run createPParam("memberUrFirstHeadName",memberUrFirstHeadName,'c').



                if num-entries(memberUrFirstHeadName,' ') > 0 then do:
                   memberDirlastname = entry(1,memberUrFirstHeadName,' ').
                   if num-entries(memberUrFirstHeadName,' ') > 1 then do:
                      memberDirfirstname = entry(2,memberUrFirstHeadName,' ').
                      if num-entries(memberUrFirstHeadName,' ') > 2 then
                         memberDirmiddlename = entry(3,memberUrFirstHeadName,' ').
                   end.
                end.

                run createPParam("memberDirfirstname",memberDirfirstname,'c').
                run createPParam("memberDirlastname",memberDirlastname,'c').
                run createPParam("memberDirmiddlename",memberDirmiddlename,'c').

                find first txb.sub-cod where txb.sub-cod.acc = txb.cif.cif and txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "lnopf" use-index dcod no-lock no-error.
                if avail txb.sub-cod  then  do:
                   find  first t-org_form where t-org_form.lnopf_id = txb.sub-cod.ccode.
                   if avail t-org_form then memberOrgform = t-org_form.org_id.
                end.

                run createPParam("memberOrgform",memberOrgform,'c').

            end.
            else do:
                memberAcFirstName = ''.
                memberAcSecondName = ''.
                memberAcMiddleName = ''.
                v-str = trim(txb.cif.name).
                if (memberType = '3') and (v-str begins "ИП ") then v-str = trim(substring(v-str,4)).
                if num-entries(v-str,' ') > 0 then memberAcSecondName = entry(1,v-str,' ').
                if num-entries(v-str,' ') >= 2 then memberAcFirstName = entry(2,v-str,' ').
                if num-entries(v-str,' ') >= 3 then memberAcMiddleName = entry(3,v-str,' ').

                if txb.cif.geo = '021' then memberAcDocTypeCode = '1'.
                else memberAcDocTypeCode = '11'.

                v-str = replace(trim(txb.cif.pss),',',' ').

                if num-entries(v-str,' ') > 1 then memberAcDocNumber = entry(1,v-str,' ').
                else memberAcDocNumber = v-str.

                v-str2 = ''.
                if (num-entries(v-str,' ') >= 2) and entry(2,v-str,' ') = "от" then
                    do i = 1 to num-entries(v-str,' '):
                        if i <> 2 then do:
                            if v-str2 <> '' then v-str2 = v-str2 + ' '.
                            v-str2 = v-str2 + entry(i,v-str,' ').
                        end.
                    end.
                else v-str2 = v-str.

                if num-entries(v-str2,' ') >= 2 then do:
                    memberAcDocIssueDate = entry(2,v-str2,' ').
                    if length(memberAcDocIssueDate) > 10 then memberAcDocIssueDate = substring(memberAcDocIssueDate,1,10).
                    v-dt = ?.
                    v-dt = date(memberAcDocIssueDate) no-error.
                    if v-dt <> ? then memberAcDocIssueDate = replace(string(v-dt,"99/99/9999"),'/','.') + " 00:00:00".
                    else memberAcDocIssueDate = ''.
                end.
                if num-entries(v-str2,' ') >= 3 then memberAcDocWhom = entry(3,v-str2,' ').
                if num-entries(v-str2,' ') > 3 then memberAcDocWhom = entry(3,v-str2,' ') + ' ' + entry(4,v-str2,' ').

                /*
                message txb.cif.name "~n" string(txb.cif.expdt,'99/99/9999') view-as alert-box.
                */

                memberAcBirthDate = replace(string(txb.cif.expdt,'99/99/9999'),'/','.') + " 00:00:00".
                memberAcBirthPlace = txb.cif.bplace.

                run createPParam("memberAcFirstName",memberAcFirstName,'c').
                run createPParam("memberAcSecondName",memberAcSecondName,'c').
                run createPParam("memberAcMiddleName",memberAcMiddleName,'c').
                run createPParam("memberAcDocTypeCode",memberAcDocTypeCode,'c').
                run createPParam("memberAcDocNumber",memberAcDocNumber,'c').
                run createPParam("memberAcDocWhom",memberAcDocWhom,'c').
                if memberAcDocIssueDate <> '' then do:
                    run createPParam("memberAcDocIssueDate",memberAcDocIssueDate,'c').
                end.
                run createPParam("memberAcBirthDate",memberAcBirthDate,'c').
                run createPParam("memberAcBirthPlace",memberAcBirthPlace,'c').
                memberOrgform = '45'. /*из org_form.i*/
                run createPParam("memberOrgform",memberOrgform,'c').

            end.

            memberFoundersCount = 0.
            if memberType = '1' then do:
                find first txb.founder where txb.founder.cif = txb.cif.cif no-lock no-error.
                if avail txb.founder then do:
                    for each txb.founder where txb.founder.cif = txb.cif.cif no-lock:
                        memberFoundersCount = memberFoundersCount + 1.

                        if txb.founder.ftype = 'B' then do:
                            run createFParam("founderType" + string(memberFoundersCount),'1','i').
                            run createFParam("founderMainCode" + string(memberFoundersCount),txb.founder.bin,'c').

                            run parseAddress("founderReg", string(memberFoundersCount), txb.founder.adress).

                            run createFParam("founderUrName" + string(memberFoundersCount),txb.founder.name,'c').
                            run createFParam("founderUrResidenceBool" + string(memberFoundersCount),txb.founder.res,'i').
                            v-country_cod = '0'.
                            find first code-st where code-st.code = founder.country no-lock no-error.
                            if avail code-st then v-country_cod = code-st.cod-ch.
                            run createFParam("founderUrResidenceCountryCode" + string(memberFoundersCount),v-country_cod,'c').
                            run createFParam("founderUrRegWhom" + string(memberFoundersCount),txb.founder.orgreg,'c').
                            run createFParam("founderUrRegNumber" + string(memberFoundersCount),txb.founder.numreg,'c').
                            run createFParam("founderUrRegDate" + string(memberFoundersCount),replace(string(txb.founder.dtreg,"99/99/9999"),'/','.') + " 00:00:00",'c').
                            run createFParam("founderUrTaxCode" + string(memberFoundersCount),txb.founder.rnn,'c').
                        end.
                        else do:
                            run createFParam("founderType" + string(memberFoundersCount),'2','i').
                            run createFParam("founderMainCode" + string(memberFoundersCount),txb.founder.bin,'c').

                            run parseAddress("founderReg", string(memberFoundersCount),txb.founder.adress).

                            run createFParam("founderAcFirstName" + string(memberFoundersCount),txb.founder.fname,'c').
                            run createFParam("founderAcSecondName" + string(memberFoundersCount),txb.founder.sname,'c').
                            run createFParam("founderAcMiddleName" + string(memberFoundersCount),txb.founder.mname,'c').
                            run createFParam("founderAcBirthDate" + string(memberFoundersCount),replace(string(txb.founder.dtbth,"99/99/9999"),'/','.') + " 00:00:00",'c').
                            run createFParam("founderAcRegNumber" + string(memberFoundersCount),txb.founder.numreg,'c').
                            run createFParam("founderAcRegSeries" + string(memberFoundersCount),txb.founder.pserial,'c').
                            run createFParam("founderAcRegWhom" + string(memberFoundersCount),txb.founder.orgreg,'c').
                            run createFParam("founderAcRegDate" + string(memberFoundersCount),replace(string(txb.founder.dtreg,"99/99/9999"),'/','.') + " 00:00:00",'c').
                        end.

                    end.
                end.
                else
            end.
            run createPParam("memberFoundersCount",string(memberFoundersCount),'i').
        end.
    end.
end case.


