# Convert Grav to Hugo

A Small Powershelll script for converting GRAV to HUGO


There is this site that inspired me, but I ended up not using any code.
https://www.cirriustech.co.uk/blog/convert-grav-markdown-to-hugo-using-powershell/

I opted for a simple solution, enough for the migration of the posts.

Finally, there were still some final adjustments to be made.

The script copies and reformats the header in the format of **my** theme.


To use this code, you have to change the value of 3 variables: 
$dirGravPages     - Post path variable GRAV
$dirHugoPosts     - HUGO post path variable
$dirHugoPostsImg  - HUGO image path variable

ex:
$dirGravPages    = 'C:\TEMP\grav\user\pages\blog\'
$dirHugoPosts    = 'C:\TEMP\hugo-Blog\blog\content\posts\'
$dirHugoPostsImg = 'C:\TEMP\hugo-Blog\blog\static\img1\'
