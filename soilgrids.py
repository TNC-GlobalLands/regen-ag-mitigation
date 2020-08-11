from osgeo import gdal

location = "https://files.isric.org/soilgrids/latest/data/"
sg_url = f"/vsicurl?max_retry=3&retry_delay=1&list_dir=no&url={location}"

kwargs = {'format': 'GTiff', 'creationOptions': ["TILED=YES", "COMPRESS=DEFLATE", "PREDICTOR=2", "BIGTIFF=YES"]}

ds = gdal.Translate('./crop_roi_igh_py.tif', 
                    '/vsicurl?max_retry=3&retry_delay=1&list_dir=no&url=https://files.isric.org/soilgrids/latest/data/ocs/ocs_0-30cm_mean.vrt', 
                    **kwargs)
del ds

