
###########################Define Variables##################################

$reportpath = ".\ADReport.htm" 

if((test-path $reportpath) -like $false)
{
new-item $reportpath -type file
}
$smtphost = "{{SMTP_HOST}}" #needs to be a string make sure to place between quotes
$from = "{{SENDER_EMAIL}}"  #needs to be a string make sure to place between quotes
$emailSubject = "AD Health Status for XYZ"
$email1 = "{{RECEIVER_EMAIL(S)}}"  #needs to be a string make sure to place between quotes
$timeout = "60"

###############################HTml Report Content############################
$report = $reportpath

Clear-Content $report 
Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
Add-Content $report '<title>AD Status Report</title>' 
add-content $report '<STYLE TYPE="text/css">' 
add-content $report  "<!--" 
add-content $report  "td {" 
add-content $report  "font-family: Tahoma;" 
add-content $report  "font-size: 11px;" 
add-content $report  "border-top: 1px solid #999999;" 
add-content $report  "border-right: 1px solid #999999;" 
add-content $report  "border-bottom: 1px solid #999999;" 
add-content $report  "border-left: 1px solid #999999;" 
add-content $report  "padding-top: 0px;" 
add-content $report  "padding-right: 0px;" 
add-content $report  "padding-bottom: 0px;" 
add-content $report  "padding-left: 0px;" 
add-content $report  "}" 
add-content $report  "body {" 
add-content $report  "margin-left: 5px;" 
add-content $report  "margin-top: 5px;" 
add-content $report  "margin-right: 0px;" 
add-content $report  "margin-bottom: 10px;" 
add-content $report  "" 
add-content $report  "table {" 
add-content $report  "border: thin solid #000000;" 
add-content $report  "}" 
add-content $report  "-->" 
add-content $report  "</style>" 
Add-Content $report "</head>" 
Add-Content $report "<body>" 
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='Lavender'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>Active Directory Health Check</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
 
add-content $report  "<table width='100%'>" 
Add-Content $report  "<tr bgcolor='IndianRed'>" 
Add-Content $report  "<td width='5%' align='center'><B>Identity</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>PingSTatus</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>NetlogonService</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>NTDSService</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>DNSServiceStatus</B></td>" 
Add-Content $report  "<td width='10%' align='center'><B>NetlogonsTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>ReplicationTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>ServicesTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>AdvertisingTest</B></td>"
Add-Content $report  "<td width='10%' align='center'><B>FSMOCheckTest</B></td>"
 
Add-Content $report "</tr>" 

#####################################Get ALL DC Servers#################################
$getForest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()

$DCServers = $getForest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name} 


################Ping Test######

foreach ($DC in $DCServers){
$Identity = $DC
                Add-Content $report "<tr>"
if ( Test-Connection -ComputerName $DC -Count 1 -ErrorAction SilentlyContinue ) {
Write-Host $DC `t $DC `t Ping Success -ForegroundColor Green
 
		Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B> $Identity</B></td>" 
                Add-Content $report "<td bgcolor= 'Aquamarine' align=center>  <B>Success</B></td>" 

                ##############Netlogon Service Status################
		$serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "Netlogon" -ErrorAction SilentlyContinue} -ArgumentList $DC
                wait-job $serviceStatus -timeout $timeout
                if($serviceStatus.state -like "Running")
                {
                 Write-Host $DC `t Netlogon Service TimeOut -ForegroundColor Yellow
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NetlogonTimeout</B></td>"
                 stop-job $serviceStatus
                }
                else
                {
                $serviceStatus1 = Receive-job $serviceStatus
                 if ($serviceStatus1.status -eq "Running") {
 		   Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         	   $svcName = $serviceStatus1.name 
         	   $svcState = $serviceStatus1.status          
         	   Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>" 
                  }
                 else 
                  { 
       		  Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         	  $svcName = $serviceStatus1.name 
         	  $svcState = $serviceStatus1.status          
         	  Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>" 
                  } 
                }
               ######################################################
                ##############NTDS Service Status################
		$serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "NTDS" -ErrorAction SilentlyContinue} -ArgumentList $DC
                wait-job $serviceStatus -timeout $timeout
                if($serviceStatus.state -like "Running")
                {
                 Write-Host $DC `t NTDS Service TimeOut -ForegroundColor Yellow
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NTDSTimeout</B></td>"
                 stop-job $serviceStatus
                }
                else
                {
                $serviceStatus1 = Receive-job $serviceStatus
                 if ($serviceStatus1.status -eq "Running") {
 		   Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         	   $svcName = $serviceStatus1.name 
         	   $svcState = $serviceStatus1.status          
         	   Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>" 
                  }
                 else 
                  { 
       		  Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         	  $svcName = $serviceStatus1.name 
         	  $svcState = $serviceStatus1.status          
         	  Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>" 
                  } 
                }
               ######################################################
                ##############DNS Service Status################
		$serviceStatus = start-job -scriptblock {get-service -ComputerName $($args[0]) -Name "DNS" -ErrorAction SilentlyContinue} -ArgumentList $DC
                wait-job $serviceStatus -timeout $timeout
                if($serviceStatus.state -like "Running")
                {
                 Write-Host $DC `t DNS Server Service TimeOut -ForegroundColor Yellow
                 Add-Content $report "<td bgcolor= 'Yellow' align=center><B>DNSTimeout</B></td>"
                 stop-job $serviceStatus
                }
                else
                {
                $serviceStatus1 = Receive-job $serviceStatus
                 if ($serviceStatus1.status -eq "Running") {
 		   Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Green 
         	   $svcName = $serviceStatus1.name 
         	   $svcState = $serviceStatus1.status          
         	   Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>$svcState</B></td>" 
                  }
                 else 
                  { 
       		  Write-Host $DC `t $serviceStatus1.name `t $serviceStatus1.status -ForegroundColor Red 
         	  $svcName = $serviceStatus1.name 
         	  $svcState = $serviceStatus1.status          
         	  Add-Content $report "<td bgcolor= 'Red' align=center><B>$svcState</B></td>" 
                  } 
                }
               ######################################################

               ####################Netlogons status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:netlogons /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Netlogons Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>NetlogonsTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test NetLogons"))
                  {
                  Write-Host $DC `t Netlogons Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>NetlogonsPassed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Netlogons Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>NetlogonsFail</B></td>"
                  }
                }
               ########################################################
               ####################Replications status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:Replications /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Replications Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>ReplicationsTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test Replications"))
                  {
                  Write-Host $DC `t Replications Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>ReplicationsPassed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Replications Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>ReplicationsFail</B></td>"
                  }
                }
               ########################################################
	       ####################Services status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:Services /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Services Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>ServicesTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test Services"))
                  {
                  Write-Host $DC `t Services Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>ServicesPassed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Services Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>ServicesFail</B></td>"
                  }
                }
               ########################################################
	       ####################Advertising status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:Advertising /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t Advertising Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>AdvertisingTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test Advertising"))
                  {
                  Write-Host $DC `t Advertising Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>AdvertisingPassed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t Advertising Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>AdvertisingFail</B></td>"
                  }
                }
               ########################################################
	       ####################FSMOCheck status##################
               add-type -AssemblyName microsoft.visualbasic 
               $cmp = "microsoft.visualbasic.strings" -as [type]
               $sysvol = start-job -scriptblock {dcdiag /test:FSMOCheck /s:$($args[0])} -ArgumentList $DC
               wait-job $sysvol -timeout $timeout
               if($sysvol.state -like "Running")
               {
               Write-Host $DC `t FSMOCheck Test TimeOut -ForegroundColor Yellow
               Add-Content $report "<td bgcolor= 'Yellow' align=center><B>FSMOCheckTimeout</B></td>"
               stop-job $sysvol
               }
               else
               {
               $sysvol1 = Receive-job $sysvol
               if($cmp::instr($sysvol1, "passed test FsmoCheck"))
                  {
                  Write-Host $DC `t FSMOCheck Test passed -ForegroundColor Green
                  Add-Content $report "<td bgcolor= 'Aquamarine' align=center><B>FSMOCheckPassed</B></td>"
                  }
               else
                  {
                  Write-Host $DC `t FSMOCheck Test Failed -ForegroundColor Red
                  Add-Content $report "<td bgcolor= 'Red' align=center><B>FSMOCheckFail</B></td>"
                  }
                }
               ########################################################
          
} 
else
              {
Write-Host $DC `t $DC `t Ping Fail -ForegroundColor Red
		Add-Content $report "<td bgcolor= 'GainsBoro' align=center>  <B> $Identity</B></td>" 
                Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>" 
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
		Add-Content $report "<td bgcolor= 'Red' align=center>  <B>Ping Fail</B></td>"
}         

                Add-Content $report "</tr>"
                
    
     
} 

###########################################Close Table for Checks#########################
Add-Content $report "</table>"
Add-Content $report "</tr>"
######################################Open Table for Events###############################

Add-Content $report "<table width='100%'>"
Add-Content $report "<br><br>"
add-content $report  "<tr bgcolor='Lavender'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>File Replication Errors in the Past 14 Days</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report "<br>"
Add-Content $report "</table>"

Add-Content $report "<table>"

foreach($DC in $DCServers){
Add-Content $report "<th>"
add-content $report  "<font face='tahoma' color='black' size='2'><strong>$DC</strong></font>" 
Add-Content $report "</th>"
Add-Content $report "<tr>"
$EntryType = @("Warning","Error")
$FRSEvents = Get-eventlog -ComputerName $DC -LogName 'File Replication Service' -after ((Get-Date).AddDays(-14)) -Entrytype $EntryType;
    Foreach ($frse in $FRSEvents){
        $EntryType1 = $frse.EntryType | out-string;
        $time = $frse.timeGenerated | out-string;
        $message = $frse.message | out-string;
        $message = $message.Substring(0,110);
        Add-Content $report "<tr>"
        Add-content $report "<td bgcolor= 'Yellow' align=center>  $time</td>" 
        Add-Content $report "<td width='5%' bgcolor= 'Yellow' >$entryType1</td>"
        Add-Content $report "<td width=auto bgcolor= 'Yellow' nowrap>$message</td>"
        Add-Content $report "</tr>"
        }
Add-Content $report "</tr>"
}
############################################Close HTMl Table for Events###########################


Add-content $report  "</table>"               
Add-Content $report "</body>" 
Add-Content $report "</html>" 


########################################################################################
#############################################Send Email#################################


$subject = "Active Directory Health Monitor" 
$body = Get-Content ".\ADreport.htm" | out-string;
send-MailMessage -from $from -to $email1 -Subject $emailSubject -bodyasHtml -body $body -Smtpserver $smtphost
stop-process $PID
########################################################################################

########################################################################################
 
         	
		
