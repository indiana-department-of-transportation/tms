# Need this because postgres apparently does not have an "IF NOT EXISTS" syntax and
# CREATE DATABASE cannot be used inside a function like we use to ensure idempotence for
# all the other operations. NOTE: this script should be idempotent, running it n times has the same
# effect as running it once.
echo "Creating db..."
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'tms'" | grep -q 1 || psql -c "CREATE DATABASE tms;"
echo "Finished."

echo "Creating tms_app user and role..."
psql -U postgres -f sql/create_tms_user.sql
psql -tc "ALTER DATABASE tms OWNER TO tms_app"
echo "Finished."

# echo "Creating CCTV tables"
# psql -U postgres -f sql/cctv/camera_module.sql
# echo "Finished"

echo "Creating AVL tables"
psql -U postgres -f sql/avl/avl_module.sql
echo "Finished"

echo "Creating DMS tables"
psql -U postgres -f sql/dms/dms_module.sql
echo "Finished"

echo "Creating TTS tables"
psql -U postgres -f sql/tts/tts_module.sql
echo "Finished"