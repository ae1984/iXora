/* vc-oper.p
 * MODULE
        Валютный контроль
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
        --/--/2013 damir
 * BASES
        BANK COMM
 * CHANGES
        03.05.2013 damir - Внедрено Т.З. № 1107.
*/
def input parameter p-auto as char no-undo.
def input parameter p-headkey as char no-undo.
def input parameter p-head as char no-undo.

p-head = trim(p-head).
p-headkey = trim(p-headkey).

def var v-host as char no-undo.
def var dir1 as char no-undo.
def var dir2 as char no-undo.
def var v-res as logi no-undo.
def var i as inte.
def var v-head as char.
def var v-extReg as char init ".PDF".
def var v-ext as char init ".pdf".

def stream v-out.

def frame scan
    dir as char label "Путь" format "x(58)" validate(dir ne "","Путь к файлу не должен быть пустым!!!")
    help "Директория расположения загружаемого файла!!!" skip
    fname as char label "Наименование файла" format "x(44)" validate(fname ne "" and fname matches "*" + v-ext + "*","Некорректное наименование файла!Повторите ввод!")
    help "Необходимо переименовать загружаемый файл, как в поле <Наименование файла>" skip
with side-labels row 10 column 1 overlay width 66 title "ПАРАМЕТРЫ".

/**********************************************************************************************************************************************************************************/
function GetFile returns logi(input dir as char,input fname as char):
    def var v-str as char.
    dir = trim(dir). fname = trim(fname).

    input through value("ssh Administrator@`askhost` -q dir /b ' " + dir + fname + "'") no-echo.
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        if v-str matches '*the system*' or v-str matches '*file not found*' then do:
            message "Проверьте каталог" dir "- нет файлов " + fname view-as alert-box information buttons ok title " Внимание".
            return false.
        end.
    end.
    input close.
    return true.
end function.

function FindFile returns logi(input dir as char).
    def var v-str as char.
    dir = trim(dir).

    input through value("find " + dir + ";echo $?").
    repeat:
        import unformatted v-str.
    end.
    input close.
    v-str = trim(v-str).
    if v-str <> "0" then do:
        return false.
    end.
    return true.
end function.

function CopyFile returns logi(input dir1 as char,input dir2 as char):
    def var v-str as char.
    dir1 = trim(dir1). dir2 = trim(dir2).

    input through value("scp -q " + dir1 + " " + dir2 + ";echo $?").
    import unformatted v-str.
    input close.
    if v-str <> "0" then do:
        message "Ошибка копирования файла " + dir1 + " !!!" view-as alert-box information buttons ok title " Внимание " .
        return false.
    end.
    return true.
end function.

function CopyFileU returns logi(input dir1 as char,input dir2 as char):
    def var v-str as char.
    dir1 = trim(dir1). dir2 = trim(dir2).

    input through value("cp " + dir1 + " " + dir2 + ";echo $?").
    import unformatted v-str.
    input close.
    if v-str <> "0" then do:
        message "Ошибка копирования файла " + dir1 + " !!!" view-as alert-box information buttons ok title " Внимание " .
        return false.
    end.
    return true.
end function.

function CreateDir returns logi(input dir as char):
    def var v-str as char.
    def var v-host as char init "Administrator@`askhost`".
    dir = trim(dir).

    input through value("ssh " + v-host + " -q mkdir " + dir + ";echo $?").
    import unformatted v-str.
    v-str = trim(v-str).
    input close.
    if not (v-str = "0" or v-str matches "*already exists*") then do:
        message "Директория для перемещения файлов не создана " + dir + " !!!" view-as alert-box information buttons ok title " Внимание " .
        return false.
    end.
    return true.
end function.

function CrDirUnix returns logi(input dir as char).
    dir = trim(dir).
    unix silent value ("mkdir " + dir).
    unix silent value ("chmod 777 " + dir).
    return true.
end function.

function MoveFile returns logi(input dir1 as char,input dir2 as char):
    def var v-str as char.
    def var v-host as char init "Administrator@`askhost`".
    dir1 = trim(dir1). dir2 = trim(dir2).

    input through value("ssh " + v-host + " -q move " + dir1 + " " + dir2 + ";echo $?").
    import unformatted v-str.
    input close.
    if not v-str matches "*file(s) moved*" then do:
        message "Файл " + dir1 + " для перемещения не найден либо уже перемещен !!!". pause 3. hide message no-pause.
    end.
    return true.
end function.

function GetReplace returns char(input dir as char,input p-r1 as char,input p-r2 as char).
    dir = trim(dir). p-r1 = trim(p-r1). p-r2 = trim(p-r2).
    dir = replace(dir,p-r1,p-r2).
    return dir.
end function.

function RenameExt returns logi(input dir as char).
    def var v-str as char.
    def var v-host as char init "Administrator@`askhost`".
    dir = trim(dir).

    input through value("ssh " + v-host + " -q rename " + dir + "*" + v-extReg + " *" + v-ext + ";echo $?").
    import unformatted v-str.
    input close.
    if v-str <> "0" then return false.
    return true.
end function.
/**********************************************************************************************************************************************************************************/

v-host = "Administrator@`askhost`".

repeat on endkey undo,leave:
    case p-auto:
        when "1" then do: /*Просмотр документа*/
            dir = "c:/tmp/".
            fname = p-head + p-headkey + v-ext.

            dir1 = "/data/docs/valcon/".
            dir2 = "./valcon/".
            if FindFile(dir1 + fname) then do:
                if not FindFile(dir2) then CrDirUnix(dir2).
                if CopyFileU(dir1 + fname,dir2) then do:
                    run ViewDoc(dir2 + fname,output v-res).
                    if not v-res then do:
                        message "Произошла ошибка при формировании документа !!!". pause 3. hide message no-pause.
                    end.
                    else do:
                        message "Документ сформирован успешно !!!". pause 3. hide message no-pause.
                    end.
                    run DelDoc(dir2 + fname,output v-res).
                    leave.
                end.
            end.
            else do:
                message "Файл не найден !!!" view-as alert-box information buttons ok title " Внимание ". leave.
            end.
        end.
        when "2" then do: /*Загрузка документа*/
            on end-error of frame scan do:
                hide frame scan.
                leave.
            end.
            dir = "c:/tmp/".
            fname = p-head + p-headkey + v-ext.

            run ShowFrame.

            update dir with frame scan.
            update fname with frame scan.
            if GetFile(GetReplace(dir,"/","\\\\"),fname) then do:
                RenameExt(GetReplace(dir,"/","\\\\")).

                dir1 = v-host + ":" + dir + fname.
                dir2 = "/data/docs/valcon/".
                if FindFile(dir2 + fname) then do:
                    run yn("Внимание","Документ уже существует.Заменить?","","",output v-res).
                    if v-res then do:
                        run DelDoc(dir2 + fname,output v-res).
                        if CopyFile(dir1,dir2) then do:
                            message "Файл скопирован в " + dir2 + " !!!". pause 3. hide message no-pause. leave.
                        end.
                        else do:
                            message "Ошибка при копировании файла в " + dir2 + " !!!". pause 3. hide message no-pause. undo,retry.
                        end.
                    end.
                    else leave.
                end.
                else do:
                    if not FindFile(dir2) then do:
                        if CrDirUnix(dir2) then do:
                            if CopyFile(dir1,dir2) then do:
                                message "Файл скопирован в " + dir2 + " !!!". pause 3. hide message no-pause. leave.
                            end.
                            else do:
                                message "Ошибка при копировании файла в " + dir2 + " !!!". pause 3. hide message no-pause. undo,retry.
                            end.
                        end.
                        else do:
                            message "Невозможно создать директорию !!!" view-as alert-box information buttons ok title " Внимание ". leave.
                        end.
                    end.
                    else do:
                        if CopyFile(dir1,dir2) then do:
                            message "Файл скопирован в " + dir2 + " !!!". pause 3. hide message no-pause. leave.
                        end.
                        else do:
                            message "Ошибка при копировании файла в " + dir2 + " !!!". pause 3. hide message no-pause. undo,retry.
                        end.
                    end.
                end.
            end.
            else do:
                message "Файл для сохранения не найден!!!" view-as alert-box information buttons ok title " Внимание ". undo,retry.
            end.
        end.
        when "3" then do: /*Удаление документа*/
            dir = "/data/docs/valcon/".

            if p-head = "vccontrs" then do:
                v-res = false.
                run DelDocCon(inte(p-headkey),dir,output v-res).
                if v-res then do:
                    message "1.Все сканированные копии документов по контракту будут удалены !!!". pause 3. hide message no-pause.
                end.

                v-head = "vccontrs|vccardsh|vcrepuve|vcrptuv2".
                m1:
                do i = 1 to num-entries(v-head,"|"):
                    fname = trim(entry(i,v-head,"|")) + p-headkey + v-ext.
                    if FindFile(dir + fname) then do:
                        v-res = false.
                        run DelDoc(dir + fname,output v-res).
                        if v-res then do:
                            message "2.Все сканированные копии документов по контракту будут удалены !!!". pause 3. hide message no-pause. next m1.
                        end.
                    end.
                    else do: hide message no-pause. next m1. end.
                end.
                leave.
            end.
            else do:
                fname = p-head + p-headkey + v-ext.
                if FindFile(dir + fname) then do:
                    v-res = false.
                    run DelDoc(dir + fname,output v-res).
                    if v-res then do:
                        message "Сканированная копия документа удалена !!!". pause 3. hide message no-pause. leave.
                    end.
                end.
                else do: hide message no-pause. leave. end.
            end.
        end.
    end case.
end.

procedure ShowFrame:
    displ dir fname with frame scan.
end procedure.

procedure ViewDoc:
    def input parameter file as char.
    def output parameter res as logi.

    unix silent cptwin value(file).
    res = true.
end procedure.

procedure DelDocCon:
    def input parameter contract as inte.
    def input parameter dir as char.
    def output parameter res as logi.

    def var doc as char.


    for each vcdolgs where vcdolgs.contract = contract no-lock:
        doc = "vcdolgs" + string(vcdolgs.dolgs) + v-ext.
        if FindFile(dir + doc) then do:
            run DelDoc(dir + doc,output v-res).
        end.
    end.
    for each vcdocs where vcdocs.contract = contract no-lock:
        doc = "vcdocs" + string(vcdocs.docs) + v-ext.
        if FindFile(dir + doc) then do:
            run DelDoc(dir + doc,output v-res).
        end.
    end.
    for each vcps where vcps.contract = contract no-lock:
        doc = "vcps" + string(vcps.ps) + v-ext.
        if FindFile(dir + doc) then do:
            run DelDoc(dir + doc,output v-res).
        end.
    end.
    for each vcrslc where vcrslc.contract = contract no-lock:
        doc = "vcrslc" + string(vcrslc.rslc) + v-ext.
        if FindFile(dir + doc) then do:
            run DelDoc(dir + doc,output v-res).
        end.
    end.
    res = true.
end procedure.

procedure DelDoc:
    def input parameter file as char.
    def output parameter res as logi.

    unix silent value("rm " + file).
    res = true.
end procedure.



