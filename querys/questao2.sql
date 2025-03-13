USE Chinook

SELECT al.ArtistID, a.Name, COUNT(DISTINCT al.AlbumID) AS AlbumsVendidos
FROM Album al
JOIN Artist a ON al.ArtistID = a.ArtistID
JOIN Track t ON al.AlbumID = t.AlbumID
JOIN InvoiceLine il ON t.TrackID = il.TrackID
GROUP BY al.ArtistID, a.Name
HAVING COUNT(DISTINCT al.AlbumID) >= 3;