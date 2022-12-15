import psycopg2

nhAreas = []
nyAreas = []


# this file does some analytics on new hampshire and new york climbing 
# it uses some views that were precreated in datagrip, outlined in my queries file
# something like this is useful if you are thinking about moving states and what to go somewhre
# with good/ a lot of climbing

def connect_db():

    # read the password file
    try:
        # password file should be in a secure location
        pwd_file = open('.pwd')
    except OSError:
        print("Error: No authorization")
        exit()

    try:
        conn = psycopg2.connect(
            dbname="finalproject_dfbrya19",
            user="dfbrya19",
            password=pwd_file.readline(),
            host="ada.hpc.stlawu.edu"
        )
    except psycopg2.Error:
        print("Error: cannot connect to database")
        exit()
    finally:
        pwd_file.close()

    return conn

# nh is true ny is false
# this functions gets all areas that have a parent area id of the one that was passed in 
def getChildren(state, parent_id, conn):
    cmd = 'select id from areas where parent_area_id = %s'
    cur = conn.cursor()
    cur.execute(cmd, (parent_id,))
    for row in cur:
        if(state):
            nhAreas.append(row[0])
            getChildren(True, row[0], conn)
        else:
            nyAreas.append(row[0])
            getChildren(False, row[0], conn)

# gets the id from the name
def getIdFromName(name, conn):
    cmd = 'select id from areas where name= %s'
    cur = conn.cursor()
    cur.execute(cmd, (name,))
    id = ""
    # will only be one row, but still need this 
    for row in cur:
        id += row[0]
    return id

# gets how many routes that are in a list of inputted areas have an average star rating of 3 or higher, and at least two votes
def getNumOverThree(areas, conn):
    num = 0
    for area_id in areas:
        cmd = 'select count(*) from avg_ratings_with_area where avg >= 3 and area_id = %s and count > 1'
        cur = conn.cursor()
        cur.execute(cmd, (area_id,))
        # will only be one row but still need to do this
        for row in cur:
            num += row[0]
    return num

# gets the number of routes for a list of areas, and the sum of all the average ratings for climbs in those areas
def getNumRoutesAndSumAvg(areas, conn):
    sum_avg = 0
    routes_num = 0
    for area_id in areas:
        # the view 
        cmd = 'select sum_avg, num_routes from avg_route_ratings_per_area where area_id = %s'
        cur = conn.cursor()
        cur.execute(cmd, (area_id,))
        # first column is the sum of all of the route rating for that area
        # second is total number of climbs
        for row in cur:
            sum_avg += row[0]
            routes_num += row[1]

    return (sum_avg, routes_num)

        
                
if __name__ == "__main__":

    conn = connect_db()

    nhID = getIdFromName("New Hampshire", conn)
    nyID = getIdFromName("New York", conn)

    # recursively get all areas in nh and ny
    getChildren(True, nhID, conn)
    getChildren(False, nyID, conn)

    (nhAvg, nhNum) = getNumRoutesAndSumAvg(nhAreas, conn)
    (nyAvg, nyNum) = getNumRoutesAndSumAvg(nyAreas, conn)

    nhQual = getNumOverThree(nhAreas, conn)
    nyQual = getNumOverThree(nyAreas, conn)

    # need to do the final divison here to get the average 
    print("New Hampshire has " + str(nhNum) + " routes with an average rating of " + str(round(nhAvg/nhNum, 2)) + " and " + str(nhQual) + " routes with over three stars and at least two star ratings")
    print("New York has " + str(nyNum) + " routes with an average rating of " + str(round(nyAvg/nyNum, 2)) + " and " + str(nyQual) + " routes with over three stars and at least two star ratings")


# the query takes like 3 minutes becuase of all the python and connections and lots of rows, so I added the output here
"""
New Hampshire has 3406 routes with an average rating of 2.36 and 716 routes with over three stars and at least two star ratings
New York has 3249 routes with an average rating of 2.37 and 686 routes with over three stars and at least two star ratings
"""