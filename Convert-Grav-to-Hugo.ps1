clear

function date-convert-format($dateValue, $FormatDateFrom, $FormatDateTo)
{
    [datetime]$dateStamp2 = ([datetime]::parseexact($dateValue, $FormatDateFrom, [System.Globalization.CultureInfo]::InvariantCulture))
    return $dateStamp2.ToString($FormatDateTo)
}

function date-convert-utcformat($dateValue, $FormatDateFrom, $FormatDateTo)
{
    [datetime]$dateStamp2 = ([datetime]::parseexact($dateValue, $FormatDateFrom, [System.Globalization.CultureInfo]::InvariantCulture))
    $dateStamp2 = $dateStamp2.ToUniversalTime()
    return $dateStamp2.ToString($FormatDateTo)
}

function file-read($filename)
{
    $raw = Get-Content -Path $filename  -Encoding utf8
    return $raw
}

function file-write($filename, $content)
{
    Out-File -FilePath $filename -InputObject $content -Encoding utf8
}

function text-addline($text, $newline)
{
    if ($text.length -eq 0)
    {
        $text = $newline
    }
    else
    {
        $text += "`r`n" + $newline 
    }
    return $text
}

function grav-to-hugo-fix-header-replace ($raw, $tag, $newtag)
{
    $result = ""
    $fixed = 0
    $firstline = 0
    ForEach ($line in $($raw -split "`r`n"))
    {
        
        if ( ($line -eq '---') -and ($firstline -eq 1) )
        {
            $fixed = 1
        }
        $firstline = 1

        $tofix = $line.Trim().IndexOf($tag)
        if ( $fixed -eq 0 -and $tofix -eq 0 )
        {
            $line = $line.Trim()
            $line = $line.Replace($tag, $newtag)
            $fixed = 1
        }
        
        ## "line  : $line"
        $result = text-addline -text $result -newline $line
    }

    return $result
}

function grav-to-hugo-fix-header-remove ($raw, $tag)
{
    $result = ""
    $fixed = 0
    $firstline = 0
    ForEach ($line in $($raw -split "`r`n"))
    {
        
        if ( ($line -eq '---') -and ($firstline -eq 1) )
        {
            $fixed = 1
        }
        $firstline = 1

        $lineCheck = $line.Replace(" ","")
        $tofix = $lineCheck.IndexOf($tag)
        if ( $fixed -eq 0 -and $tofix -eq 0 )
        {
            $fixed = 1
            continue
        }
        
        ## "line  : $line"
        $result = text-addline -text $result -newline $line
    }

    return $result
}

function grav-to-hugo-fix-header-title ($raw)
{
    ## Exemple:
    ## title = My blog post name
    ## title = "My blog post name"

    $result = ""
    $fixed = 0
    $firstline = 0
    ForEach ($line in $($raw -split "`r`n"))
    {


        if ( ($line -eq '---') -and ($firstline -eq 1) )
        {
            $fixed = 1
        }
        $firstline = 1


        $tofix = $line.IndexOf("title")
        if ( $fixed -eq 0 -and $tofix -eq 0 )
        {
            $fixed = 1
            $line = $line.substring(5,$line.length - 5)
            $line = $line.Trim()
            $line = $line.Substring(1, $line.length - 1)
            $line = $line.Trim()
            $line = $line.replace('"','')
            $line = $line.replace("'","")
            $line = "title = " + '"' + $line + '"' 
        }
        
        ## "line  : $line"
        $result = text-addline -text $result -newline $line

    }

    return $result

}

function grav-to-hugo-fix-header-DateFormat($raw, $tag, $FormatDateFrom, $FormatDateTo)
{

    $result = ""
    $fixed = 0
    $firstline = 0
    ForEach ($line in $($raw -split "`r`n"))
    {


        if ( ($line -eq '---') -and ($firstline -eq 1) )
        {
            $fixed = 1
        }
        $firstline = 1


        $tofix = $line.IndexOf($tag)
        if ( $fixed -eq 0 -and $tofix -eq 0 )
        {
            $fixed = 1
            
            $date = $line.substring($tag.length, $line.length - $tag.length)
            $date = $date.Replace("'","")
            $date = $date.Replace('"','')
            $date = $date.Trim()

            $line = $line.Substring(0, $tag.length)
            $line = $line.Trim()
            try {
                $dateOk = date-convert-format $date $FormatDateFrom $FormatDateTo
                $line = $tag + $dateOk
            }
            catch
            {
                $line = $tag + $date
            }
            
        }
        
        ## "line  : $line"
        $result = text-addline -text $result -newline $line

    }

    return $result

}

function list-item-trim($item)
{

    $item = $item.replace("`r","")
    $list = $item.replace("`n","")
    $item = $item.replace("`t","")
    $item = $item.Trim()

    if ($item.substring(0,1) -eq '-')
    {
        $item = $item.substring(1).Trim()
        return $item
    }
    else
    {
        return $item
    }

}
function list-text-trim($list)
{
    $list = $list.Replace('[', '["');
    $list = $list.Replace(',', '","');
    $list = $list.Replace(']', '"]');

    $n = 20
    while ($n -gt 0)
    {
        $n -= 1
        $list = $list.Replace('" ', '"');
        $list = $list.Replace(' "', '"');
    }

    return $list

}
function grav-to-hugo-fix-header-add-quotes-on-list($raw, $tag)
{

    $result = ""
    $fixed = 0
    $firstline = 1

    $begin = 0
    $end = 0
    $list = ''

    $use_brackets = -1

    ForEach ($line in $($raw -split "`r`n"))
    {


        if ( ($line -eq '---') -and ($firstline -eq 0) )
        {
            $fixed = 1
        }
        $firstline = 0


        $tofix = $line.Trim().IndexOf($tag)
        if ( $fixed -eq 0 -and $tofix -eq 0 -and $begin -eq 0)
        {

            $begin =  1
            $line = $line.substring($tag.length)
            $list = $line.Trim().substring(1)

            if ( ($line.Trim().IndexOf('[') -gt -1) -and ($use_brackets -eq -1))
            {
                $use_brackets = 1
            }
            if ( ($line.Trim().IndexOf('-') -gt -1) -and ($use_brackets -eq -1))
            {
                $use_brackets = 0
            }


            if ( ($use_brackets -eq 1) -and ($line.IndexOf(']') -gt -1) )
            {
                $end = 1
                $list = list-text-trim $list.Trim()
                #"list-online: $list"

                $line = $tag + ' = ' + $list.Trim()
                $result = text-addline -text $result -newline $line
            }


            if ($use_brackets -eq 0)
            {
                $item = list-item-trim $list
                $list = '['+$item 
            }

            continue

        } 


        if ($fixed -eq 0 -and $begin -eq 1 -and $end -eq 0)
        {

            if ( ($line.Trim().IndexOf('[') -gt -1) -and ($use_brackets -eq -1))
            {
                $use_brackets = 1
            }
            if ( ($line.Trim().IndexOf('-') -gt -1) -and ($use_brackets -eq -1))
            {
                $use_brackets = 0
            }


            if ($use_brackets -eq 1)
            {
                if ( ($line.IndexOf(']') -gt -1) -and $end -eq 0)
                {
                    $end = 1
                    $list += $line.Trim()  
                    $list = list-text-trim $list
                    $line = $tag + ' = ' + $list
                    $result = text-addline -text $result -newline $line
                }
                else
                {
                    $list += $line.Trim()
                }
                continue
            }



            if ($use_brackets -eq 0)
            {
                if ( ($end -eq 0))
                {
                    $line = $line.trim()
                    if ($line.Substring(0,1) -eq '-')
                    {
                        $item = list-item-trim $line
                        if ($list.Length -eq 0)
                        {
                            $list = '['
                        }
                        else
                        {
                            $list = $list+','
                        }
                        $list += $item
                    }
                    else
                    {
                        #end
                        $end = 1
                        $list = $list + ']'
                        $list = list-text-trim $list
                        $list = $tag + ' = ' + $list
                        $result = text-addline -text $result -newline $list
                        $result = text-addline -text $result -newline $line
                    }
                }
            }
            continue

        }
        
        $line = $line
        $result = text-addline -text $result -newline $line
 
    }

    return $result

}


function grav-to-hugo-fix-header-BeginEnd($raw)
{

    $result = ""
    $fixed = 0
    $firstline = 1

    ForEach ($line in $($raw -split "`r`n"))
    {


        if ( ($line -eq '---') -and ($firstline -eq 1) )
        {
            $line = '+++'
            $firstline = 0
        }


        if ( ($line -eq '---') -and ($fixed -eq 0) )
        {
            $line = '+++'
            $fixed = 1
        }

        $result = text-addline -text $result -newline $line

    }

    return $result

}


function grav-to-hugo-fix-Replace($raw, $Old, $New)
{
    $raw = $raw.Replace($Old, $New)

    return $raw
}

$dirGravPages    = 'C:\TEMP\SiteWeb\grav\user\pages\blog\'
$dirHugoPosts    = 'C:\TEMP\SiteWeb\hugo-Blog\blog\content\posts\'
$dirHugoPostsImg = 'C:\TEMP\SiteWeb\hugo-Blog\blog\static\img1\'


$files = Get-ChildItem -Recurse $dirGravPages

foreach ($f in $files)
{

    $name = $f.Name
    $path = $f.DirectoryName
    $ext = $f.Extension
    $fullpath = $f.FullName

    if ($ext -eq '.md')
    {

        "***  "+$fullpath
        $DirName = (Get-Item $fullpath).Directory.Name
        $pos= $DirName.IndexOf(".")
        if ($pos -gt 3)
        {
            $newName = $DirName.Substring($pos+1)
            "New name : $newName"
            $fullNew = $dirHugoPosts + $newName + ".md"
            
            Copy-Item $fullpath -Destination $fullNew -Force


            $copy = $path+"\*.png"
            Copy-Item -path $copy -Destination $dirHugoPostsImg -Force  

            $copy = $path+"\*.jpg"
            Copy-Item -path $copy -Destination $dirHugoPostsImg -Force
            
            $raw  = file-read $fullNew

            $raw = grav-to-hugo-fix-header-title  $raw
            
            $raw = grav-to-hugo-fix-header-replace $raw 'published: true'  'draft = false'
            
            $raw = grav-to-hugo-fix-header-replace $raw 'published: false' 'draft = true'

            $raw = grav-to-hugo-fix-header-replace $raw 'date:' 'date = '
            
            $raw = grav-to-hugo-fix-header-DateFormat $raw 'date = '  'dd-MM-yyyy HH:mm'  'yyyy-MM-dd'
            $raw = grav-to-hugo-fix-header-DateFormat $raw 'date = '  'yyyy-MM-dd HH:mm'  'yyyy-MM-dd'

            $raw = grav-to-hugo-fix-header-remove $raw "media_order:"

            $raw = grav-to-hugo-fix-header-remove $raw "taxonomy:"
            
            $raw = grav-to-hugo-fix-header-replace $raw 'category:' 'categories ='
            $raw = grav-to-hugo-fix-header-add-quotes-on-list $raw 'categories'
            
            $raw = grav-to-hugo-fix-header-replace $raw 'tag:' 'tags ='
            $raw = grav-to-hugo-fix-header-add-quotes-on-list $raw 'tags'

            $raw = grav-to-hugo-fix-header-remove $raw "publish_date:"
            $raw = grav-to-hugo-fix-header-remove $raw "visible:"

            $raw = grav-to-hugo-fix-header-BeginEnd $raw "---" "+++"

            $raw = grav-to-hugo-fix-Replace $raw "![](/"             "![](/img1/"
            $raw = grav-to-hugo-fix-Replace $raw "![](/data/images/" "![](/img1/"
            $raw = grav-to-hugo-fix-Replace $raw "![](data/images/"  "![](/img1/"

            file-write $fullNew $raw

        }
        
    }
    
}
