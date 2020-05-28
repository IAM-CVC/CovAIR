% OutExcelFile should be without extension
function [  ] = Export2Excel4R( Prec,Rec,Methods,OutExcelFile)

NSamples=length(Prec);

%%% Prepare xlswrite1
Excel = actxserver ('Excel.Application');
File=OutExcelFile;
if ~exist(File,'file')
    ExcelWorkbook = Excel.workbooks.Add;
    ExcelWorkbook.SaveAs(File);
    ExcelWorkbook.Close(false);
end
invoke(Excel.Workbooks,'Open',File);

HeaderPos={'Precision', 'Recall','offset','Method'};
Sheet='CovidScores';
xlswrite1([OutExcelFile],HeaderPos,Sheet,'A1');
ExcelLine=2;
for kf=1:NSamples
    for k=1:length(Methods)
    ExcelData={Prec(k,kf),Rec(k,kf),kf,Methods{k}};
    
    xlswrite1([OutExcelFile],ExcelData,Sheet,['A',num2str(ExcelLine)]);
    ExcelLine=ExcelLine+1;
    end
end

invoke(Excel.ActiveWorkbook,'Save');
Excel.Quit
Excel.delete
clear Excel
system('taskkill /F /IM EXCEL.EXE');


end

