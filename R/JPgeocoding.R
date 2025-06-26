#' Geocode Japanese addresses using geocoding.jp API
#'
#' This function retrieves geographic coordinates (longitude and latitude)
#' for a vector of Japanese addresses by querying the public geocoding API at \url{https://www.geocoding.jp}.
#' The result can be returned as a `data.frame` or as an `sf` object.
#'
#' @param address A character vector of address strings in Japanese.
#' @param encoding Character string indicating the encoding to use for the address when constructing the URL. Default is `"UTF-8"`.
#' @param sleep_sec Number of seconds to wait between API requests to avoid overloading the server. Default is `10`. Values under 10 will trigger a warning.
#' @param return_as_sf Logical. If `TRUE`, the result is returned as an `sf` object with WGS84 coordinates (`EPSG:4326`). Default is `FALSE`.
#' @param with_address Logical. If `TRUE`, the original address strings are included in the output. Default is `FALSE`.
#'
#' @return A `data.frame` with columns `"lng"` and `"lat"` (and optionally `"address"`), or an `sf` object with point geometry if `return_as_sf = TRUE`.
#' Addresses that fail to resolve will result in rows with `NA` values.
#'
#' @details
#' This function accesses a public API service that may have rate limits or temporary downtime.
#' It is strongly recommended to keep at least 10 seconds between requests (`sleep_sec >= 10`) to avoid being blocked.
#'
#' @note This function depends on the availability of \url{https://www.geocoding.jp} and requires the packages `xml2` and `sf`.
#'
#' @examples
#' \dontrun{
#' addresses <- c("東京都国立市中2-1", "京都府京都市左京区吉田本町")
#'
#' # Get coordinates as data.frame
#' df <- JPgeocoding(addresses, with_address = TRUE)
#'
#' # Get coordinates as sf object
#' sf_result <- JPgeocoding(addresses, return_as_sf = TRUE, with_address = TRUE)
#' library(mapview)
#' mapview::mapview(sf_result)
#' }
#' @export
JPgeocoding <- function(address, encoding = "UTF-8", sleep_sec = 10,
                        return_as_sf = FALSE, 
                        with_address = FALSE){
  if(sleep_sec < 10){
    warning("The developer asks users to set at least 10 seconds interval.")
  }
  
  n <- length(address)
  coords <- data.frame(matrix(NA, n, 2, dimnames = list(1:n, c("lng", "lat"))))
  i <- 1
  
  cat("Starting geocoding...\n")
  while(i <= n){
    cat(sprintf("  [%d] %s\n", i, address[i]))
    
    address_encoded <- URLencode(address[i])
    url <- paste0("https://www.geocoding.jp/api/?q=", address_encoded)
    
    doc <- tryCatch(xml2::read_xml(url), error = function(e) NULL)
    
    if (!is.null(doc)) {
      lat <- xml2::xml_text(xml2::xml_find_first(doc, "//lat"))
      lng <- xml2::xml_text(xml2::xml_find_first(doc, "//lng"))
      
      if (!is.na(lat) && !is.na(lng)) {
        coords[i, ] <- c(lng, lat)
      } else {
        warning(sprintf("No lat/lng found for address [%d]: %s", i, address[i]))
      }
    } else {
      warning(sprintf("Failed to fetch XML for address [%d]: %s", i, address[i]))
    }
    
    i <- i + 1
    Sys.sleep(sleep_sec)
  }
  
  cat("...DONE\n\n")
  
  if(with_address){
    coords <- data.frame(address = address, coords)
  }
  
  if(return_as_sf){
    sf_obj <- sf::st_as_sf(coords, coords = c("lng", "lat"), crs = 4326)
    return(sf_obj)
  } else {
    return(coords)
  }
}
