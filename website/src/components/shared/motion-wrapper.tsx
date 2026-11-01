import { motion } from 'motion/react';

export const MotionWrapper = ({
  children,
  duration = 0.5,
  delay = 0.2,
}: {
  children: React.ReactNode;
  delay?: number;
  duration?: number;
}) => {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true }}
      transition={{ duration, delay }}>
      {children}
    </motion.div>
  );
};
