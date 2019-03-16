#run this first to enable execute ps1
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

function CreatePrivateMSMQFromList($queueList, $ynIsTransactional, $ynIsPrivate, $user, $permission)
{
    $ynIsPrivate = "Y"
    ForEach ($queueName in $queueList) 
    {
        $fullQueueName = "private$\" + $queueName
        If ([System.Messaging.MessageQueue]::Exists($fullQueueName))
        {
            Write-Host($fullQueueName + " queue already exists")
        }
        else
        {
            CreateMSMQQueue $queueName $ynIsPrivate $ynIsTransactional $user $permission 
        }
    }
}


function CreateMSMQQueue($queuename, $YNPrivate, $YNTransactional, $user, $permission) 
{

    if ($permission -ne "all" -and $permission -ne "restricted") 
        {
           Write-Host "Error: fifth parameter "permission" must have value 'all' or 'restricted'" 
           exit 
        }

    [Reflection.Assembly]::LoadWithPartialName("System.Messaging")


    if ($YNPrivate -ieq "Y")
        { 
          $queuename = ".\private$\" + $queuename 
        }

    if ($YNTransactional -ieq "Y")
        {
            $transactional = 1
            Write-Host "Creating a transactional queue."
        }
    else
        {
            $transactional = 0
            Write-Host "Creating a non-trasactional queue"
        }
    
    $msgQueue = [System.Messaging.MessageQueue]::Create($queuename, $transactional) 
    
    if($msgQueue -eq $null)
        {
            Write-Host "Error: got a 'null' back from the Create MSMQ function" 
            exit
        }
    
    $msgQueue.label = $queuename
           
    if ($permission -ieq "all")
        {
            Write-Host "Granting all permissions to "  $User
            $msgQueue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Allow) 
        }
    else
        {
            Write-Host "Restricted Control for user: "  $User
            Write-Host ""
            $msgQueue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::DeleteMessage, [System.Messaging.AccessControlEntryType]::Set) 
            $msgQueue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::GenericWrite, [System.Messaging.AccessControlEntryType]::Allow) 
            $msgQueue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::PeekMessage, [System.Messaging.AccessControlEntryType]::Allow) 
            $msgQueue.SetPermissions($User, [System.Messaging.MessageQueueAccessRights]::ReceiveJournalMessage, [System.Messaging.AccessControlEntryType]::Allow)
        }
}


function DeleteMSMQQueue($queuename, $YNPrivate) 
{
    Write-Host "DeleteMSMQQUEUE QueueName: " + $queuename
    if ($YNPrivate -ieq "Y")
    { 
      $queuename = ".\private$\" + $queuename 
    }
    Write-Host "Delete Queue: " + $queuename
    [System.Messaging.MessageQueue]::Delete($queuename)
}

cls

$queueArray = "TestMSMQ1","TestMSMQ2"
CreatePrivateMSMQFromList $queueArray "Y" "Y" "Administrator" "all"
#use the following instead of Create to Delete the Queue
#DeleteMSMQQueue $myQueueName $ynIsPrivate 