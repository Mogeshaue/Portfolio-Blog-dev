# Blog Sync Script
# This script syncs blog posts from the Blogs-dev repository

$blogsDevPath = "c:\Users\mokes\iQube-Projects\portfolio\Blogs-dev"
$portfolioPath = "c:\Users\mokes\iQube-Projects\portfolio\Astro-template"

Write-Host "🔄 Syncing blogs from Blogs-dev repository..." -ForegroundColor Cyan

# Check if Blogs-dev exists
if (!(Test-Path $blogsDevPath)) {
    Write-Host "❌ Blogs-dev repository not found. Cloning..." -ForegroundColor Yellow
    Set-Location "c:\Users\mokes\iQube-Projects\portfolio"
    git clone https://github.com/Mogeshaue/Blogs-dev.git
}

# Pull latest changes from Blogs-dev
Write-Host "📥 Pulling latest blogs..." -ForegroundColor Cyan
Set-Location $blogsDevPath
git pull

# Copy blog posts (excluding drafts)
Write-Host "📋 Copying blog posts..." -ForegroundColor Cyan
$blogSource = "$blogsDevPath\src\content\blog\*"
$blogDest = "$portfolioPath\src\content\blog\"

Get-ChildItem -Path "$blogsDevPath\src\content\blog" -Directory | ForEach-Object {
    if ($_.Name -ne "drafts") {
        Write-Host "  ✓ Copying $($_.Name)..." -ForegroundColor Green
        Copy-Item -Path $_.FullName -Destination $blogDest -Recurse -Force
    }
}

Write-Host "✅ Blog sync complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Blog posts in portfolio:" -ForegroundColor Cyan
Get-ChildItem -Path "$portfolioPath\src\content\blog" | Select-Object Name | Format-Table

Set-Location $portfolioPath
