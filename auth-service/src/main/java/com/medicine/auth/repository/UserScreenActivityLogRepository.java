package com.medicine.auth.repository;

import com.medicine.auth.entity.UserScreenActivityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserScreenActivityLogRepository extends JpaRepository<UserScreenActivityLog, Long> {
}
