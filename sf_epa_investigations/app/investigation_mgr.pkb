CREATE OR REPLACE PACKAGE BODY investigation_mgr IS
/*
This package is copied (with some minor re-formatting) from Steven Feuerstein's article of 5 May 2021:

[Feuertip #8: “On the cheap” testing](https://www.insum.ca/feuertip-8-on-the-cheap-testing/)

It is used here as an example to demonstrate unit testing.
*/
    PROCEDURE pack_details (
        p_investigation_id  IN  NUMBER,
        p_spray_id          IN  NUMBER,
        p_pesticide_id      IN  NUMBER
    ) IS

      /* all the rows for this investigation_id */

        CURSOR investigation_cur IS
        SELECT
            id,
            spray_id,
            pesticide_id
        FROM
            investigation_details
        WHERE
            investigation_id = p_investigation_id;

      /* This will hold the parameter values. */

        l_ids_from_app          investigation_cur%rowtype;

      /* This one holds the values from a row in the table */
        l_investigation_detail  investigation_cur%rowtype;

      /* Control loop through matching detail rows and whether or not to update */
        l_done                  BOOLEAN := false;
        l_do_update             BOOLEAN := false;

        PROCEDURE initialize_local_ids IS
            l_count INTEGER;
        BEGIN

      /* Copy the parameter values to this local record. That way, I can override
         the values with null after I've put them into the table, and know that
         I am getting closer to being done.
         BUT also set the ID to null if it is already in the table for this
         investigation ID.

      */
            SELECT
                COUNT(*)
            INTO l_count
            FROM
                investigation_details
            WHERE
                    investigation_id = p_investigation_id
                AND pesticide_id = p_pesticide_id;

            l_ids_from_app.pesticide_id :=
                CASE
                    WHEN l_count = 0 THEN
                        p_pesticide_id
                END;
            SELECT
                COUNT(*)
            INTO l_count
            FROM
                investigation_details
            WHERE
                    investigation_id = p_investigation_id
                AND spray_id = p_spray_id;

            l_ids_from_app.spray_id :=
                CASE
                    WHEN l_count = 0 THEN
                        p_spray_id
                END;
        END;

        PROCEDURE check_for_update (
            p_id_from_app    IN OUT  NUMBER,
            p_id_for_update  IN OUT  NUMBER,
            p_do_update      IN OUT  BOOLEAN
        ) IS
        BEGIN
            IF
                p_id_from_app IS NOT NULL AND p_id_for_update IS NULL
            THEN
                p_do_update := true;
                p_id_for_update := p_id_from_app;

             /* We are going to update with this value, so mark it as "done" */
                p_id_from_app := NULL;
            END IF;
        END;

        PROCEDURE insert_if_needed (
            p_ids_from_app IN investigation_cur%rowtype
        ) IS
        BEGIN

         /* If at least one ID still needs to be stored, time to insert.
            Note that any columns that don't have an id "left" are set to null,
            so they can be "packed" later */
            IF p_ids_from_app.pesticide_id IS NOT NULL OR p_ids_from_app.spray_id IS NOT NULL THEN
                INSERT INTO investigation_details (
                    investigation_id,
                    spray_id,
                    pesticide_id
                ) VALUES (
                    p_investigation_id,
                    p_ids_from_app.spray_id,
                    p_ids_from_app.pesticide_id
                );

            END IF;
        END;

    BEGIN
        initialize_local_ids;
        IF p_investigation_id IS NOT NULL THEN
            OPEN investigation_cur;
            WHILE NOT l_done LOOP
                FETCH investigation_cur INTO l_investigation_detail;
                l_done := investigation_cur%notfound;
                IF NOT l_done THEN
               /* Can we update any null columns in the currently fetched row? */
                    check_for_update(l_ids_from_app.pesticide_id, l_investigation_detail.pesticide_id, l_do_update);
                    check_for_update(l_ids_from_app.spray_id, l_investigation_detail.spray_id, l_do_update);

               /* If there is at least one column that can be updated, we update all three,
                  BUT we update the column to its current value (see check_for_update for this logic). */
                    IF l_do_update THEN
                        UPDATE investigation_details
                        SET
                            pesticide_id = l_investigation_detail.pesticide_id,
                            spray_id = l_investigation_detail.spray_id
                        WHERE
                            id = l_investigation_detail.id;

                        l_do_update := false;
                    END IF;

               /* If we've taken care of all the IDs passed into the procedure, we can stop.
                  No insert will be needed. We could also exit the loop because no more rows
                  are found. In which pesticide, an insert *will* be performed if at least one
                  of the IDs are still not null. */

                    l_done :=
                        l_ids_from_app.pesticide_id IS NULL AND l_ids_from_app.spray_id IS NULL;
                END IF;

            END LOOP;

            CLOSE investigation_cur;
            insert_if_needed(l_ids_from_app);
        END IF;

    END;

END;
/
SHO ERR